/*
 * mytheme_cart/js/apple-vars.js
 *
 * Inject Apple light-palette CSS variables onto document.documentElement
 * so nexus_cart's auto-loaded custom.css can map them into the SPA's
 * --vl-* variable surface (custom.css does --vl-primary: var(--primary)
 * etc. on :host, :root). Custom properties inherit through the SPA's
 * open Shadow DOM, so this hits every Vue component inside.
 *
 * Loaded as an external script because WHMCS strips inline <script>,
 * <style>, <link>, and style="..." from cart TPL output -- only
 * <script src=...> survives the sanitizer. See viewcart.tpl for the
 * load order: this script must run BEFORE main.min.js so the SPA
 * paints with the right palette on first frame.
 *
 * Values mirror apple-client-area/css/apple-theme.css's light mode.
 */
(function () {
    var s = document.documentElement.style;
    var v = {
        // Primary / status
        'primary':            '#0071e3',
        'primary-lifted':     '#0077ed',
        'primary-accented':   '#005bb5',
        'secondary':          '#f5f5f7',
        'secondary-lifted':   '#ebebef',
        'secondary-accented': '#e8e8ed',
        'success':            '#34c759',
        'success-lifted':     '#30b751',
        'success-accented':   '#2aa24a',
        'info':               '#0071e3',
        'info-lifted':        '#0077ed',
        'info-accented':      '#005bb5',
        'notice':             '#ff9f0a',
        'notice-lifted':      '#ff8e00',
        'notice-accented':    '#e07a00',
        'warning':            '#ff9500',
        'warning-lifted':     '#f08a00',
        'warning-accented':   '#d97a00',
        'error':              '#ff3b30',
        'error-lifted':       '#ef352b',
        'error-accented':     '#d62d24',

        // Grayscale / neutral
        'grayscale':          '#1d1d1f',
        'grayscale-lifted':   '#2c2c2e',
        'grayscale-accented': '#000000',
        'neutral':            '#6e6e73',
        'neutral-lifted':     '#86868b',
        'neutral-accented':   '#4a4a4f',

        // Text / border / background hierarchy
        'text':               '#1d1d1f',
        'text-lifted':        '#6e6e73',
        'text-accented':      '#000000',
        'text-muted':         '#86868b',
        'text-inverted':      '#ffffff',

        'border':             '#e8e8ed',
        'border-muted':       '#f0f0f5',
        'border-lifted':      '#d2d2d7',
        'border-accented':    '#1d1d1f',

        'bg':                 '#fbfbfd',
        'bg-muted':           '#f5f5f7',
        'bg-lifted':          '#ffffff',
        'bg-accented':        '#fafafa',
        'bg-inverted':        '#1d1d1f',

        // Typography (Apple SF Pro sizing)
        'text-xs':            '11.5px',
        'text-sm':            '13px',
        'text-md':            '15px',
        'text-lg':            '17px',

        // Spacing / focus rings
        'outline-sm':         '2px',
        'outline-md':         '3px',
        'outline-lg':         '4px',

        // Rounding -- Apple uses generous rounding + pills
        'rounding-sm':        '8px',
        'rounding-md':        '12px',
        'rounding-lg':        '999px',

        'letter-spacing':     '-0.008em',
        'disabled-opacity':   '0.5'
    };
    for (var k in v) s.setProperty('--' + k, v[k]);
})();
