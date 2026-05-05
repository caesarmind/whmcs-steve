<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Oops!</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { margin: 30px 40px; background: #fbfbfd; color: #1d1d1f; font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', Helvetica, Arial, sans-serif; }
        .error-container { max-width: 640px; margin: 80px auto; padding: 40px; background: #fff; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.06); }
        h1 { font-size: 48px; font-weight: 600; margin-bottom: 8px; }
        h2 { font-size: 22px; font-weight: 400; color: #6e6e73; margin-bottom: 24px; }
        p { margin-bottom: 12px; line-height: 1.47; }
        a { color: #0066cc; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .back-to-home { margin-top: 32px; }
        .debug { margin-top: 32px; padding: 16px; background: #f5f5f7; border-radius: 8px; font-family: 'SF Mono', monospace; font-size: 13px; color: #6e6e73; }
    </style>
</head>
<body>
<div class="error-container">
    <h1>Oops!</h1>
    <h2>Something went wrong and we couldn't process your request.</h2>
    <p>Please go back to the previous page and try again.</p>
    <p>If the problem persists, please <a href="mailto:{{email}}">contact us</a>.</p>
    <p class="back-to-home"><a href="{{systemurl}}">&laquo; Back to Homepage</a></p>
    {{environmentIssues}}
    <p class="debug">{{adminHelp}}<br/>{{stacktrace}}</p>
</div>
</body>
</html>
