<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PHP + Docker</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background: #0d1117;
      color: #e6edf3;
      font-family: system-ui, -apple-system, sans-serif;
    }

    main {
      text-align: center;
      padding: 2rem;
    }

    .stack {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 1.5rem;
      margin-bottom: 2rem;
    }

    .stack img {
      height: 160px;
      width: auto;
    }

    .plus {
      font-size: 2.5rem;
      font-weight: 300;
      color: #8b949e;
      line-height: 1;
    }

    .status {
      color: #3fb950;
      font-size: 1.1rem;
      letter-spacing: 0.02em;
    }
  </style>
</head>
<body>
  <main>
    <div class="stack">
      <img src="/images/PHP.png" alt="PHP">
      <span class="plus">+</span>
      <img src="/images/Docker.png" alt="Docker">
    </div>
    <p class="status">* Application running</p>
  </main>
</body>
</html>
