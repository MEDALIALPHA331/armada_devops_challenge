import { test, expect } from 'vitest';

const isCi = process.env.NODE_ENV === 'ci';

//SKIP mock in CI
test.skipIf(isCi)('GET /', async () => {
  const response = await fetch('http://localhost:8000');
  const data = await response.text();

  expect(response.status).toBe(200);
  expect(data).toBe('Hello Armada');
});

//JUST TO AVOID CI TO FAIL BECAUSE THERE IS NOT TEST FILES
