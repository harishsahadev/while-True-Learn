// Reads the rendered poster.html and returns every box, image and block of text with its
// position (CSS px, origin top-left of the page) and style. Used by extract_layout.R.
(() => {
  const css = (el, p, pseudo) => getComputedStyle(el, pseudo || null).getPropertyValue(p);
  const px = v => parseFloat(v) || 0;
  const colour = s => {                     // "rgb(a, b, c)" / "rgba(a, b, c, d)" -> {hex, a}
    const m = s.match(/rgba?\(([^)]+)\)/); if (!m) return null;
    const v = m[1].split(',').map(t => parseFloat(t));
    const hex = v.slice(0, 3).map(n => Math.round(n).toString(16).padStart(2, '0')).join('').toUpperCase();
    return { hex, a: v.length > 3 ? v[3] : 1 };
  };
  const R = r => ({ x: r.left, y: r.top, w: r.width, h: r.height });
  const items = [];
  const isInline = el => css(el, 'display') === 'inline';

  // ---- boxes (backgrounds, borders, circles) --------------------------------------------
  function box(el) {
    if (el.tagName === 'IMG' && !(colour(css(el, 'background-color')) || {}).a) return;
    const bg = colour(css(el, 'background-color'));
    const bw = px(css(el, 'border-left-width')), bc = colour(css(el, 'border-left-color'));
    const tw = px(css(el, 'border-top-width')), tc = colour(css(el, 'border-top-color'));
    const r = el.getBoundingClientRect(); if (r.width < 1 || r.height < 1) return;
    const rad = px(css(el, 'border-top-left-radius'));
    const round = css(el, 'border-top-left-radius').includes('%') || rad >= Math.min(r.width, r.height) / 2 - 0.5;
    const hasBg = bg && bg.a > 0, hasBorder = bw > 0 && bc && bc.a > 0;
    if (hasBg || hasBorder)
      items.push({ t: 'box', ...R(r), fill: hasBg ? bg : null, line: hasBorder ? { ...bc, w: bw } : null,
                   shape: round ? 'ellipse' : rad > 0 ? 'round' : 'rect', radius: rad });
    else if (tw > 0 && tc && tc.a > 0)    // top border only (table rows)
      items.push({ t: 'line', x: r.left, y: r.top + tw / 2, w: r.width, h: 0, line: { ...tc, w: tw } });
    // ::before dot (section headings)
    const b = getComputedStyle(el, '::before');
    if (b.content && b.content !== 'none' && px(b.width) > 0) {
      const cb = colour(b.backgroundColor);
      const pl = px(css(el, 'padding-left')), pt = px(css(el, 'padding-top')), pb = px(css(el, 'padding-bottom'));
      const w = px(b.width), h = px(b.height), cy = r.top + pt + (r.height - pt - pb) / 2;
      items.push({ t: 'box', x: r.left + pl, y: cy - h / 2, w, h, fill: cb, line: null, shape: 'ellipse', radius: w / 2 });
    }
  }

  // ---- images ---------------------------------------------------------------------------
  function image(el) {
    const r = el.getBoundingClientRect();
    const l = px(css(el, 'padding-left')) + px(css(el, 'border-left-width'));
    const t = px(css(el, 'padding-top')) + px(css(el, 'border-top-width'));
    items.push({ t: 'img', src: decodeURIComponent(new URL(el.src).pathname), alt: el.alt,
                 x: r.left + l, y: r.top + t, w: r.width - 2 * l, h: r.height - 2 * t });
  }

  // ---- text: each block element with inline content becomes one text box ------------------
  function runs(el, out) {
    for (const n of el.childNodes) {
      if (n.nodeType === 3) {
        const s = n.textContent.replace(/\s+/g, ' ');
        if (!s) continue;
        const p = n.parentElement;
        out.push({ text: s, size: px(css(p, 'font-size')) * 0.75, weight: parseInt(css(p, 'font-weight')),
                   italic: css(p, 'font-style') === 'italic', colour: colour(css(p, 'color')).hex,
                   spacing: px(css(p, 'letter-spacing')) * 0.75 });
      } else if (n.nodeType === 1) {
        if (n.tagName === 'BR') out.push({ br: true });
        else if (isInline(n)) runs(n, out);
      }
    }
    return out;
  }
  function textBlock(el) {
    const hasInline = [...el.childNodes].some(n => (n.nodeType === 3 && n.textContent.trim()) ||
                                                    (n.nodeType === 1 && isInline(n) && n.textContent.trim()));
    if (!hasInline) return;
    const rs = runs(el, []);
    // trim leading/trailing spaces and spaces next to line breaks
    for (let i = 0; i < rs.length; i++) {
      if (rs[i].br) continue;
      if (i === 0 || rs[i - 1].br) rs[i].text = rs[i].text.replace(/^ /, '');
      if (i === rs.length - 1 || rs[i + 1].br) rs[i].text = rs[i].text.replace(/ $/, '');
    }
    // where the text actually sits (skips ::before dots, padding, list markers)
    const rg = document.createRange(); let x0 = 1e9, y0 = 1e9, y1 = -1e9, rh = 0;
    const walk = node => { for (const n of node.childNodes) {
      if (n.nodeType === 3 && n.textContent.trim()) { rg.selectNodeContents(n);
        for (const q of rg.getClientRects()) { if (q.top < y0) rh = q.height;
          x0 = Math.min(x0, q.left); y0 = Math.min(y0, q.top); y1 = Math.max(y1, q.bottom); } }
      else if (n.nodeType === 1 && isInline(n)) walk(n); } };
    walk(el);
    const r = el.getBoundingClientRect();
    const right = r.right - px(css(el, 'padding-right')) - px(css(el, 'border-right-width'));
    const align = css(el, 'text-align');
    const li = el.tagName === 'LI';
    const indent = li ? x0 - el.parentElement.getBoundingClientRect().left - px(css(el.parentElement, 'border-left-width')) : 0;
    const left = li ? x0 - indent : (align === 'right' ? r.left + px(css(el, 'padding-left')) : x0);
    const lh = px(css(el, 'line-height')) || rh;
    const top = y0 - (lh - rh) / 2;           // top of the first line box, not of the glyphs
    items.push({ t: 'text', x: left, y: top, w: right - left, h: y1 - top + (lh - rh) / 2, runs: rs, bullet: li, indent,
                 align: align === 'center' ? 'center' : align === 'right' || align === 'end' ? 'right' : 'left',
                 lineHeight: lh * 0.75, tag: el.tagName.toLowerCase(),
                 cls: el.className || '' });
  }

  function visit(el) {
    if (['SCRIPT', 'STYLE', 'HEAD', 'TITLE', 'META'].includes(el.tagName)) return;
    if (css(el, 'display') === 'none') return;
    if (el !== document.body && el !== document.documentElement) box(el);
    if (el.tagName === 'IMG') { image(el); return; }
    if (!isInline(el)) textBlock(el);
    for (const c of el.children) visit(c);
  }
  visit(document.body);
  const b = document.body.getBoundingClientRect();
  const bgUrl = css(document.body, 'background-image').match(/url\("?(.*?)"?\)/);
  return JSON.stringify({ page: { w: b.width, h: b.height }, pageColour: colour(css(document.body, 'background-color')).hex,
                          background: bgUrl ? decodeURIComponent(new URL(bgUrl[1]).pathname) : null, items });
})()
