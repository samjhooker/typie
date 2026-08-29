import messenger from 'thesvg/messenger';
import slack from 'thesvg/slack';
import chrome from 'thesvg/chrome';
import vscode from 'thesvg/visual-studio-code';
import notion from 'thesvg/notion';
import figma from 'thesvg/figma';
import discord from 'thesvg/discord';
import zoom from 'thesvg/zoom';
import telegram from 'thesvg/telegram';
import whatsapp from 'thesvg/whatsapp';
import imessage from 'thesvg/imessage';
import gmail from 'thesvg/gmail';
import gdocs from 'thesvg/google-docs';
import safari from 'thesvg/safari';
import arc from 'thesvg/arc';
import cursor from 'thesvg/cursor';
import appleNotes from '../assets/apple-notes-icon.svg?raw';

const svg = (mod) => (typeof mod === 'string' ? mod : (mod.svg ?? String(mod)));

const notes =
  appleNotes ||
  '<svg viewBox="0 0 24 24" fill="none"><rect x="4" y="3" width="16" height="18" rx="3" fill="#fff" stroke="#e2b93b" stroke-width="1.4"/><rect x="4" y="3" width="16" height="5.5" rx="2.4" fill="#f7cf47"/><path d="M8 12.5h8M8 16h5" stroke="#d9a520" stroke-width="1.5" stroke-linecap="round"/></svg>';

const mail =
  '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" fill="#3b82f6"/><path d="m4.5 7.5 7.5 6 7.5-6" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>';

export const APPS = [
  { n: 'Messages', s: svg(imessage) },
  { n: 'Slack', s: svg(slack) },
  { n: 'WhatsApp', s: svg(whatsapp) },
  { n: 'Telegram', s: svg(telegram) },
  { n: 'Discord', s: svg(discord) },
  { n: 'Zoom', s: svg(zoom) },
  { n: 'Messenger', s: svg(messenger) },
  { n: 'Mail', s: mail },
  { n: 'Gmail', s: svg(gmail) },
  { n: 'Chrome', s: svg(chrome) },
  { n: 'Safari', s: svg(safari) },
  { n: 'Arc', s: svg(arc) },
  { n: 'VS Code', s: svg(vscode) },
  { n: 'Cursor', s: svg(cursor) },
  { n: 'Notes', s: notes },
  { n: 'Notion', s: svg(notion) },
  { n: 'Figma', s: svg(figma) },
  { n: 'Docs', s: svg(gdocs) },
];

export const APP_ROWS = [
  APPS.slice(0, Math.ceil(APPS.length / 2)),
  APPS.slice(Math.ceil(APPS.length / 2)),
];
