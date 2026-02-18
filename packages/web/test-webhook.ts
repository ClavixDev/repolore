/**
 * Test webhook signature verification
 * Usage: npx tsx test-webhook.ts
 */

import crypto from 'crypto';

const secret = process.env.GITHUB_APP_WEBHOOK_SECRET || 'test-secret';
const payload = JSON.stringify({ action: 'created', installation: { id: 123 } });

const signature = 'sha256=' + crypto.createHmac('sha256', secret).update(payload).digest('hex');

console.log('Payload:', payload);
console.log('Signature:', signature);
console.log('');
console.log('Use these values to test the webhook endpoint:');
console.log('Header x-hub-signature-256:', signature);
console.log('Header x-github-event: installation');
