# =============================================================================
# app/app.R
# "What New Zealand builds": an interactive summary of the three research
# questions. Run from RStudio (open this file, click "Run App"), or:
#   shiny::runApp("app")
# It uses only the saved models and processed data, so knit the notebooks first.
# =============================================================================

library(shiny)
library(bslib)
suppressPackageStartupMessages({
  library(tidyverse)
  library(ranger)
  library(plotly)
})

# ---- Locate the project and load helpers -------------------------------------
find_proj_root <- function(path = getwd()) {
  path <- normalizePath(path)
  repeat {
    if (length(list.files(path, pattern = "\\.Rproj$"))) return(path)
    parent <- dirname(path)
    if (parent == path) stop("No .Rproj file found above ", getwd())
    path <- parent
  }
}
proj_root <- find_proj_root()
source(file.path(proj_root, "R", "utils_data.R"))
source(file.path(proj_root, "R", "utils_models.R"))
path_of <- function(...) file.path(proj_root, ...)
addResourcePath("figs", path_of("outputs", "figures"))   # serve the notebook figures to the browser
addResourcePath("assets", path_of("communication", "assets"))   # pitch-deck font and background

short_name <- function(x) str_remove(x, " District| City")
pct  <- function(x, d = 0) sprintf(paste0("%+.", d, "f%%"), 100 * x)
dollars <- function(x) paste0("$", format(round(x), big.mark = ","))
fig_img <- function(file, alt) tags$img(src = file, alt = alt, style = "max-width: 100%; height: auto;")

# ---- RQ1: cost per m² --------------------------------------------------------
rq1_hist <- readRDS(path_of("data", "processed", "rq1_model_data.rds"))
fm1      <- readRDS(path_of("outputs", "models", "rq1", "rq1_final_models.rds"))
rq1_latest <- fm1$latest |> arrange(ta)
# slider ranges from the data (with headroom for "what if")
max_alt    <- ceiling(1.5 * max(expm1(rq1_latest$log_resid_alt_real)) / 1e6)
max_nonres <- ceiling(1.5 * max(expm1(rq1_latest$log_nonres_real)) / 1e6)
max_houses <- ceiling(1.5 * max(exp(rq1_latest$log_houses_n)))

# turn the sliders (natural units) into the model's features for one district
rq1_newdata <- function(row, inp) {
  row |>
    mutate(log_resid_alt_real = log1p(inp$alt * 1e6),
           dwell_per_1000     = inp$per1000,
           log_houses_n       = log(max(inp$houses, 1)),
           rel_house_m2       = log(1 + inp$size / 100),
           log_nonres_real    = log1p(inp$nonres * 1e6),
           houses_yoy         = log(1 + inp$yoy / 100),
           multiunit_share    = inp$multi / 100,
           ta     = factor(ta, levels = fm1$factor_levels$ta),
           region = factor(region, levels = fm1$factor_levels$region))
}
rq1_predict <- function(nd) {
  c(linear = as.numeric(predict(fm1$lm_district$fit, newdata = nd)),
    forest = predict(fm1$rf_drivers, nd)$predictions)
}

# ---- RQ2: building markets ---------------------------------------------------
rq2  <- readRDS(path_of("data", "processed", "rq2_district_features.rds"))
fit2 <- readRDS(path_of("outputs", "models", "rq2", "rq2_clusters.rds"))
vars2 <- fit2$vars
members2 <- fit2$membership |> left_join(rq2$raw |> select(ta, all_of(vars2), dwellings), by = "ta")
# k-means numbered its clusters arbitrarily; the notebook renumbered them by size
km_to_market <- map_int(seq_len(nrow(fit2$centres_z)),
                        \(o) unique(members2$cluster[fit2$kmeans$cluster == o]))
market_cols <- set_names(c("#5C5148", "#C76B0A", "#FBAC4D"), fit2$cluster_names)   # as in the poster and slides

transform2 <- function(df) df |>
  mutate(across(c(apt_share, retire_share, town_share, nonres_share), sqrt),
         dwell_per_1000 = log(dwell_per_1000), volatility = log(volatility))
to_z <- function(df) scale(as.matrix(transform2(df)[vars2]),
                           center = fit2$scaling$center[vars2], scale = fit2$scaling$scale[vars2])
X2   <- to_z(rq2$raw)
pca2 <- prcomp(X2)
nearest_market <- function(z) {
  d <- apply(fit2$centres_z[, vars2], 1, \(cen) sqrt(sum((z - cen)^2)))
  list(market = fit2$cluster_names[km_to_market[which.min(d)]], distances = d)
}
profile2 <- members2 |> group_by(market) |> summarise(across(all_of(vars2), median))

# ---- RQ3: rise or fall -------------------------------------------------------
rq3d   <- readRDS(path_of("data", "processed", "rq3_model_data.rds"))
res3   <- readRDS(path_of("outputs", "models", "rq3", "rq3_results.rds"))
fc3    <- rq3d$forecast |> arrange(ta)
fc3$prob <- predict(res3$final_logistic, fc3, type = "response")
acc3   <- res3$test$accuracy[res3$test$model == "Logistic regression"]
auc3   <- res3$test$auc[res3$test$model == "Logistic regression"]

# ---- UI -----------------------------------------------------------------------
# ---- Look: the group's pitch-deck style (peach background, orange accents, Open Sauce One) ----
pitch <- list(ink = "#2B2B2B", muted = "#5C5148", orange = "#FBAC4D", dark = "#C76B0A", border = "#EDB46E",
              tint = "#FFF8EF")
theme <- bs_theme(version = 5, bg = pitch$tint, fg = pitch$ink, primary = pitch$dark, secondary = pitch$muted,
                  base_font = "'Open Sauce One', Arial, sans-serif", heading_font = "'Open Sauce One', Arial, sans-serif") |>
  bs_add_rules("
    .navbar { background: rgba(255, 248, 239, 0.88) !important; border-bottom: 1px solid #EDB46E; }
    .navbar-brand { font-weight: 800; display: flex; align-items: center; gap: .5rem; }
    .navbar-brand::before { content: ''; width: .8rem; height: .8rem; border-radius: 50%; background: #FBAC4D; }
    .card:not(.bslib-value-box), .bslib-sidebar-layout { background: rgba(255, 255, 255, 0.62) !important;
                                   border: 1px solid #EDB46E !important; border-radius: .9rem !important; }
    .bslib-sidebar-layout > .sidebar { background: rgba(255, 248, 239, 0.75) !important; }
    .card-header { background: transparent; font-weight: 700; border-bottom: 1px solid #EDB46E; }
    .bslib-value-box { border: 0 !important; border-radius: .9rem !important; }
    .bslib-value-box.bg-primary, .bslib-value-box.bg-primary * { color: #FFFFFF !important; }
  ")
# font files and background image: referenced from the page (not the compiled theme CSS), so the
# relative addresses also work when the app runs under a sub-path such as shinyapps.io
pitch_head <- tags$head(tags$style(HTML(paste0(
  paste0("@font-face { font-family: 'Open Sauce One'; src: url('assets/fonts/OpenSauceOne-", c("Regular", "Bold", "ExtraBold"),
         ".ttf'); font-weight: ", c(400, 700, 800),
         # the font has no superscript two: leave that character to Arial so "m²" still shows
         "; unicode-range: U+0000-00B1, U+00B3-FFFF; }", collapse = "\n"),
  "\nbody { background: #FFF3E5 url('assets/pitch_background.png') center top / cover fixed no-repeat; }"))))

slider_pct <- function(id, label, min, max, value, step = 1)
  sliderInput(id, label, min = min, max = max, value = value, step = step, post = "%")

ui <- page_navbar(
  title = "What New Zealand builds",
  header = pitch_head,
  id = "nav",
  theme = theme,
  fillable = FALSE,            # pages scroll; cards keep their natural height
  nav_panel(
    "Overview", value = "overview",
    layout_columns(
      col_widths = c(12, 4, 4, 4),
      card(card_body(
        h4("Building consents in New Zealand, 1990–2026"),
        p("Stats NZ publishes the number, value and floor area of every building consent issued by each council,
           every month. We used the August 2026 release to answer three questions, one with each family of methods
           from STAT462. Each tab lets you explore a question with the models we fitted."),
        p(class = "text-muted small",
          "Group 8, while True: learn(): Andrew Boulton, Harish Sahadev M, Niwesh Baraj. Data: Stats NZ, CC BY 4.0.
           All dollar values are real (June 2026 dollars, including 15% GST).")
      )),
      card(card_header("RQ1 · Regression"),
           card_body(fig_img("figs/communication/c04_rq1_drivers.png", "What makes a district dearer"),
                     strong("What drives the cost per m² of new houses?"),
                     p("Location matters most. Of the measured drivers, renovation spending (+8% to +11%) and fast
                        population growth raise cost. The drivers explain about 15% of the gap between districts.
                        Best model: linear regression with district, within about 8% of actual cost in 2020–26."))),
      card(card_header("RQ2 · Clustering"),
           card_body(fig_img("figs/communication/c05_rq2_markets.png", "Three kinds of building market"),
                     strong("What kinds of building markets are there?"),
                     p("Three: house-building districts (30), slow provincial districts (21) and urban
                        medium-density markets (15). k-means and hierarchical clustering agree on 60 of 66
                        districts, but the groups summarise a continuum rather than sharply separate types."))),
      card(card_header("RQ3 · Classification"),
           card_body(fig_img("figs/communication/c08_rq3_accuracy.png", "Prediction accuracy"),
                     strong("Will a district's consents rise next year?"),
                     p(sprintf("Only modestly predictable: logistic regression is right %.0f%% of the time on 2018–2025
                                (AUC %.2f), against 53%% for the best simple rule. Districts rise and fall together with
                                the national cycle.", 100 * acc3, auc3))))
    )
  ),

  nav_panel(
    "RQ1 · Cost per m²", value = "rq1",
    layout_sidebar(
      sidebar = sidebar(
        width = 320,
        selectInput("d1", "District", choices = rq1_latest$ta, selected = "Selwyn District"),
        p(class = "small text-muted", "Sliders start at the district's average over its last four quarters.
          Move them to ask \"what if\"."),
        sliderInput("alt", "Residential alterations ($m per quarter)", 0, max_alt, 10, step = 0.5),
        sliderInput("per1000", "New dwellings per 1,000 residents (12 months)", 0, 40, 5, step = 0.1),
        sliderInput("houses", "New houses in the quarter", 1, max_houses, 50, step = 1),
        slider_pct("size", "House size vs rest of NZ", -50, 50, 0),
        sliderInput("nonres", "New non-residential work ($m per quarter)", 0, max_nonres, 10, step = 0.5),
        slider_pct("yoy", "Houses vs same quarter last year", -80, 200, 0),
        slider_pct("multi", "Multi-unit share of new dwellings", 0, 90, 10),
        actionButton("reset1", "Reset to the district's values", class = "btn-sm")
      ),
      layout_columns(
        col_widths = c(4, 4, 4, 12, 6, 6),
        value_box(title = "Predicted cost (linear regression, with district)", value = textOutput("v_linear"),
                  p(textOutput("v_linear_rel", inline = TRUE)), theme = "primary"),
        value_box(title = "Predicted cost (random forest, drivers only)", value = textOutput("v_rf"),
                  p(textOutput("v_rf_rel", inline = TRUE)), theme = "secondary"),
        value_box(title = "Actual, last four quarters", value = textOutput("v_actual"),
                  p(textOutput("v_actual_rel", inline = TRUE)), theme = "light"),
        card(card_header("Real cost per m² of new houses: this district vs the rest of New Zealand"),
             plotOutput("p_hist1", height = 300)),
        card(card_header("What makes a district dearer to build in"),
             fig_img("figs/communication/c04_rq1_drivers.png", "Effect of each driver")),
        card(card_header("Location premium before and after the drivers"),
             fig_img("figs/rq1/fig26_district_premium.png", "District premium"))
      )
    )
  ),

  nav_panel(
    "RQ2 · Building markets", value = "rq2",
    layout_sidebar(
      sidebar = sidebar(
        width = 320,
        selectInput("d2", "District", choices = sort(members2$ta), selected = "Selwyn District"),
        p(class = "small text-muted", "Sliders start at the district's 2016–2026 profile. Change them to see which
          market a district with that profile would belong to."),
        slider_pct("apt", "Apartments (share of new dwellings)", 0, 50, 1, step = 0.5),
        slider_pct("town", "Townhouses, flats, units", 0, 60, 10, step = 0.5),
        slider_pct("retire", "Retirement-village units", 0, 25, 4, step = 0.5),
        sliderInput("dpk", "New dwellings per 1,000 residents a year", 1, 30, 5, step = 0.1),
        slider_pct("growth2", "Growth: 2021–26 vs 2016–21", -50, 150, 0),
        slider_pct("vol", "Volatility (typical yearly change)", 15, 100, 30),
        slider_pct("cost2", "Construction cost vs other districts", -20, 35, 0),
        sliderInput("hm2", "Average new house (m²)", 120, 220, 180),
        slider_pct("nonres2", "Non-residential share of building value", 5, 75, 30),
        actionButton("reset2", "Reset to the district's values", class = "btn-sm")
      ),
      layout_columns(
        col_widths = c(6, 6, 6, 6, 12),
        value_box(title = "The district's market", value = textOutput("v_market"),
                  p(textOutput("v_market_fit", inline = TRUE)), theme = "primary"),
        value_box(title = "Market for the profile on the sliders", value = textOutput("v_whatif"),
                  p("nearest cluster centre"), theme = "secondary"),
        card(card_header("Districts on the first two principal components"),
             plotlyOutput("p_pca2", height = 420)),
        card(card_header("Profile: this district vs the median of each market"),
             div(style = "font-size: 0.85rem;", tableOutput("t_profile2"))),
        card(card_header("Members of each market"), uiOutput("u_members2"))
      )
    )
  ),

  nav_panel(
    "RQ3 · Rise or fall", value = "rq3",
    layout_sidebar(
      sidebar = sidebar(
        width = 320,
        selectInput("d3", "District", choices = fc3$ta, selected = "Selwyn District"),
        p(class = "small text-muted", "Sliders start at the district's 2025 values. National conditions stay at
          their 2025 values."),
        slider_pct("g1", "Change in new dwellings, 2024 to 2025", -80, 150, 0),
        slider_pct("dev5", "2025 vs the district's previous five-year average", -80, 150, 0),
        slider_pct("h2h1", "Second half of 2025 vs first half", -70, 200, 0),
        slider_pct("altg", "Change in renovation spending", -60, 100, 0),
        slider_pct("multi3", "Multi-unit share of new dwellings", 0, 90, 10),
        sliderInput("dpk3", "New dwellings per 1,000 residents", 0, 40, 5, step = 0.1),
        actionButton("reset3", "Reset to the district's values", class = "btn-sm")
      ),
      layout_columns(
        col_widths = c(6, 6, 12, 6, 6),
        value_box(title = "Probability that new dwellings rise in 2026", value = textOutput("v_prob"),
                  p(textOutput("v_prob_note", inline = TRUE)), theme = "primary"),
        value_box(title = "How much to trust it", value = sprintf("%.0f%% accurate", 100 * acc3),
                  p(sprintf("on 2018–2025 (AUC %.2f). A coin toss is 50%%.", auc3)), theme = "light"),
        card(card_header("Logistic regression: probability of a rise in 2026, every district"),
             plotOutput("p_all3", height = 1000)),
        card(card_header("Districts rise and fall together"),
             fig_img("figs/communication/c07_rq3_together.png", "Share of districts rising by year")),
        card(card_header("What moves the odds"),
             fig_img("figs/rq3/fig06_odds_ratios.png", "Odds ratios"))
      )
    )
  ),
  nav_spacer(),
  nav_item(tags$a("Stats NZ data", href = "https://www.stats.govt.nz/information-releases/building-consents-issued-august-2026",
                  target = "_blank"))
)

# ---- Server -------------------------------------------------------------------
server <- function(input, output, session) {

  # open a tab from the address, e.g. http://127.0.0.1:port/?tab=rq2
  observeEvent(session$clientData$url_search, once = TRUE, {
    tab <- parseQueryString(session$clientData$url_search)$tab
    if (!is.null(tab)) nav_select("nav", tab)
  })

  # ---------------- RQ1 ----------------
  row1 <- reactive(rq1_latest |> filter(ta == input$d1))
  fill_rq1 <- function() {
    r <- row1()
    updateSliderInput(session, "alt", value = round(expm1(r$log_resid_alt_real) / 1e6, 1))
    updateSliderInput(session, "per1000", value = round(r$dwell_per_1000, 1))
    updateSliderInput(session, "houses", value = round(exp(r$log_houses_n)))
    updateSliderInput(session, "size", value = round(100 * (exp(r$rel_house_m2) - 1)))
    updateSliderInput(session, "nonres", value = round(expm1(r$log_nonres_real) / 1e6, 1))
    updateSliderInput(session, "yoy", value = round(100 * (exp(r$houses_yoy) - 1)))
    updateSliderInput(session, "multi", value = round(100 * r$multiunit_share))
  }
  observeEvent(input$d1, fill_rq1())
  observeEvent(input$reset1, fill_rq1())

  pred1 <- reactive({
    inp <- list(alt = input$alt, per1000 = input$per1000, houses = input$houses, size = input$size,
                nonres = input$nonres, yoy = input$yoy, multi = input$multi)
    p <- rq1_predict(rq1_newdata(row1(), inp))
    list(rel = p, dollars = exp(p) * row1()$loo_cost_m2)
  })
  output$v_linear     <- renderText(paste0(dollars(pred1()$dollars["linear"]), " / m²"))
  output$v_linear_rel <- renderText(paste(pct(exp(pred1()$rel["linear"]) - 1), "vs the rest of NZ"))
  output$v_rf        <- renderText(paste0(dollars(pred1()$dollars["forest"]), " / m²"))
  output$v_rf_rel    <- renderText(paste(pct(exp(pred1()$rel["forest"]) - 1), "vs the rest of NZ"))
  output$v_actual    <- renderText(paste0(dollars(row1()$real_cost_m2), " / m²"))
  output$v_actual_rel <- renderText(paste("rest of NZ:", dollars(row1()$loo_cost_m2), "/ m²,", row1()$last_quarter))

  output$p_hist1 <- renderPlot(bg = "transparent", {
    rq1_hist |> filter(ta == input$d1) |>
      mutate(date = year + (as.integer(as.character(quarter)) - 1) / 4) |>
      select(date, `This district` = real_cost_m2, `Rest of NZ` = loo_cost_m2) |>
      pivot_longer(-date) |>
      ggplot(aes(date, value, colour = name)) +
      geom_vline(xintercept = 2020, linetype = 2, colour = "grey60") +
      geom_line(linewidth = 0.8) +
      scale_colour_manual(values = c("This district" = pitch$dark, "Rest of NZ" = pitch$muted)) +
      scale_y_continuous(labels = scales::label_dollar(accuracy = 1)) +
      labs(x = NULL, y = "Real $ per m²", colour = NULL,
           caption = "Quarters with at least 5 new houses. Dashed line: start of the test period.") +
      theme_minimal(base_size = 13) + theme(legend.position = "top")
  })

  # ---------------- RQ2 ----------------
  row2 <- reactive(members2 |> filter(ta == input$d2))
  fill_rq2 <- function() {
    r <- row2()
    updateSliderInput(session, "apt", value = round(100 * r$apt_share, 1))
    updateSliderInput(session, "town", value = round(100 * r$town_share, 1))
    updateSliderInput(session, "retire", value = round(100 * r$retire_share, 1))
    updateSliderInput(session, "dpk", value = round(r$dwell_per_1000, 1))
    updateSliderInput(session, "growth2", value = round(100 * (exp(r$growth) - 1)))
    updateSliderInput(session, "vol", value = round(100 * r$volatility))
    updateSliderInput(session, "cost2", value = round(100 * (exp(r$rel_cost) - 1)))
    updateSliderInput(session, "hm2", value = round(r$house_m2))
    updateSliderInput(session, "nonres2", value = round(100 * r$nonres_share))
  }
  observeEvent(input$d2, fill_rq2())
  observeEvent(input$reset2, fill_rq2())

  whatif2 <- reactive({
    prof <- tibble(apt_share = input$apt / 100, retire_share = input$retire / 100, town_share = input$town / 100,
                   dwell_per_1000 = input$dpk, growth = log(1 + input$growth2 / 100),
                   volatility = input$vol / 100, rel_cost = log(1 + input$cost2 / 100),
                   house_m2 = input$hm2, nonres_share = input$nonres2 / 100)
    z <- to_z(prof)[1, ]
    c(nearest_market(z), list(pc = as.numeric(z %*% pca2$rotation[, 1:2])))
  })
  output$v_market     <- renderText(as.character(row2()$market))
  output$v_market_fit <- renderText(sprintf("silhouette %.2f (%s)", row2()$silhouette,
    if (row2()$silhouette < 0) "closer to another market" else if (row2()$silhouette < 0.15) "on the border" else "clearly in it"))
  output$v_whatif <- renderText(whatif2()$market)

  output$p_pca2 <- renderPlotly({
    df <- as_tibble(pca2$x[, 1:2]) |> mutate(name = short_name(rq2$raw$ta), ta = rq2$raw$ta) |>
      left_join(members2 |> select(ta, market), by = "ta")
    sel <- df |> filter(ta == input$d2)
    plot_ly() |>
      add_markers(data = df, x = ~PC1, y = ~PC2, color = ~market, colors = market_cols, text = ~name,
                  hoverinfo = "text", marker = list(size = 9, opacity = 0.8)) |>
      add_markers(x = sel$PC1, y = sel$PC2, name = "Selected district", hoverinfo = "skip",
                  marker = list(size = 18, color = "rgba(0,0,0,0)", line = list(color = "black", width = 2))) |>
      add_markers(x = whatif2()$pc[1], y = whatif2()$pc[2], name = "Slider profile", hoverinfo = "skip",
                  marker = list(size = 14, symbol = "x", color = "black")) |>
      layout(paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
             xaxis = list(title = "PC1: building intensity, bigger houses →"),
             yaxis = list(title = "PC2: denser and dearer →"), legend = list(orientation = "h", y = -0.15))
  })

  output$t_profile2 <- renderTable({
    lab <- c(apt_share = "Apartments %", retire_share = "Retirement %", town_share = "Townhouses %",
             dwell_per_1000 = "Dwellings per 1,000", growth = "Growth %", volatility = "Volatility %",
             rel_cost = "Cost vs others %", house_m2 = "House m²", nonres_share = "Non-residential %")
    nice <- function(v, x) case_when(v %in% c("growth", "rel_cost") ~ 100 * (exp(x) - 1),
                                     v %in% c("dwell_per_1000", "house_m2") ~ x, TRUE ~ 100 * x)
    short_market <- c("House-building", "Provincial", "Urban")      # same order as fit2$cluster_names
    tibble(Feature = lab[vars2],
           District = map_dbl(vars2, \(v) nice(v, row2()[[v]])),
           !!!set_names(map(fit2$cluster_names, \(m)
             map_dbl(vars2, \(v) nice(v, profile2[[v]][profile2$market == m]))), short_market))
  }, digits = 1, spacing = "xs", width = "100%")

  output$u_members2 <- renderUI({
    blocks <- map(fit2$cluster_names, function(m) {
      d <- members2 |> filter(market == m) |> arrange(name)
      div(h6(sprintf("%s (%d)", m, nrow(d)), style = paste0("color:", market_cols[m])),
          p(class = "small", paste(d$name, collapse = ", ")))
    })
    do.call(layout_columns, c(list(col_widths = c(4, 4, 4)), blocks))
  })

  # ---------------- RQ3 ----------------
  row3 <- reactive(fc3 |> filter(ta == input$d3))
  fill_rq3 <- function() {
    r <- row3()
    updateSliderInput(session, "g1", value = round(100 * (exp(r$growth_1y) - 1)))
    updateSliderInput(session, "dev5", value = round(100 * (exp(r$dev_5y) - 1)))
    updateSliderInput(session, "h2h1", value = round(100 * (exp(r$h2_vs_h1) - 1)))
    updateSliderInput(session, "altg", value = round(100 * (exp(r$alt_growth) - 1)))
    updateSliderInput(session, "multi3", value = round(100 * r$multiunit_share))
    updateSliderInput(session, "dpk3", value = round(r$dwell_per_1000, 1))
  }
  observeEvent(input$d3, fill_rq3())
  observeEvent(input$reset3, fill_rq3())

  prob3 <- reactive({
    nd <- row3() |> mutate(growth_1y = log(1 + input$g1 / 100), dev_5y = log(1 + input$dev5 / 100),
                           h2_vs_h1 = log(1 + input$h2h1 / 100), alt_growth = log(1 + input$altg / 100),
                           multiunit_share = input$multi3 / 100, dwell_per_1000 = input$dpk3)
    predict(res3$final_logistic, nd, type = "response")
  })
  output$v_prob <- renderText(sprintf("%.0f%%", 100 * prob3()))
  output$v_prob_note <- renderText(sprintf("%s · with the district's own 2025 values: %.0f%%",
    if (prob3() > 0.5) "leans towards a rise" else "leans towards a fall", 100 * row3()$prob))

  output$p_all3 <- renderPlot(bg = "transparent", {
    fc3 |> mutate(name = fct_reorder(short_name(ta), prob), selected = ta == input$d3) |>
      ggplot(aes(prob, name, fill = selected)) +
      geom_col(width = 0.75) +
      geom_vline(xintercept = 0.5, linetype = 2) +
      scale_fill_manual(values = c(`TRUE` = pitch$dark, `FALSE` = pitch$orange), guide = "none") +
      scale_x_continuous(labels = scales::percent, limits = c(0, 1)) +
      labs(x = "Probability of a rise in 2026 (using 2025 values)", y = NULL) +
      theme_minimal(base_size = 12) + theme(axis.text.y = element_text(size = 9), panel.grid.major.y = element_blank())
  })
}

shinyApp(ui, server)
