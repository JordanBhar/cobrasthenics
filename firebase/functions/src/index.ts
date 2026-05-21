import { onRequest } from "firebase-functions/v2/https";

export const health = onRequest((request, response) => {
  response.json({ ok: true });
});
