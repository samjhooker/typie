import messenger from 'thesvg/messenger';
import slack from 'thesvg/slack';
import chrome from 'thesvg/chrome';
import vscode from 'thesvg/visual-studio-code';
import notion from 'thesvg/notion';
import figma from 'thesvg/figma';
import discord from 'thesvg/discord';
import github from 'thesvg/github';
import linear from 'thesvg/linear';
import spotify from 'thesvg/spotify';
import zoom from 'thesvg/zoom';
import telegram from 'thesvg/telegram';
import whatsapp from 'thesvg/whatsapp';
import imessage from 'thesvg/imessage';
import gmail from 'thesvg/gmail';
import outlook from 'thesvg/microsoft-outlook';
import teams from 'thesvg/microsoft-teams';
import gdocs from 'thesvg/google-docs';
import gsheets from 'thesvg/google-sheets';
import gslides from 'thesvg/google-slides';
import gdrive from 'thesvg/google-drive';
import gcal from 'thesvg/google-calendar';
import safari from 'thesvg/safari';
import arc from 'thesvg/arc';
import firefox from 'thesvg/firefox';
import cursor from 'thesvg/cursor';
import signal from 'thesvg/signal';
import xcode from 'thesvg/xcode';
import obsidian from 'thesvg/obsidian';
import things from 'thesvg/things';
import todoist from 'thesvg/todoist';
import asana from 'thesvg/asana';
import trello from 'thesvg/trello';
import jira from 'thesvg/jira';
import confluence from 'thesvg/confluence';
import clickup from 'thesvg/clickup';
import airtable from 'thesvg/airtable';
import miro from 'thesvg/miro';
import loom from 'thesvg/loom';
import canva from 'thesvg/canva';
import instagram from 'thesvg/instagram';
import photoshop from 'thesvg/photoshop';
import illustrator from 'thesvg/illustrator';
import raycast from 'thesvg/raycast';
import alfred from 'thesvg/alfred';
import warp from 'thesvg/warp';
import dropbox from 'thesvg/dropbox';
import icloud from 'thesvg/icloud';
import linkedin from 'thesvg/linkedin';
import x from 'thesvg/x';
import reddit from 'thesvg/reddit';
import youtube from 'thesvg/youtube';
import claude from 'thesvg/claude';
import word from 'thesvg/microsoft-word';
import excel from 'thesvg/microsoft-excel';
import powerpoint from 'thesvg/microsoft-powerpoint';
import grammarly from 'thesvg/grammarly';
import spark from 'thesvg/spark';
import appleNotes from '../assets/apple-notes-icon.svg?raw';

const svg = (mod) => (typeof mod === 'string' ? mod : (mod.svg ?? String(mod)));

const notes =
  appleNotes ||
  '<svg viewBox="0 0 24 24" fill="none"><rect x="4" y="3" width="16" height="18" rx="3" fill="#fff" stroke="#e2b93b" stroke-width="1.4"/><rect x="4" y="3" width="16" height="5.5" rx="2.4" fill="#f7cf47"/><path d="M8 12.5h8M8 16h5" stroke="#d9a520" stroke-width="1.5" stroke-linecap="round"/></svg>';

const mail =
  '<svg viewBox="0 0 24 24" fill="none"><rect x="3" y="5" width="18" height="14" rx="3" fill="#3b82f6"/><path d="m4.5 7.5 7.5 6 7.5-6" stroke="#fff" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>';

export const APPS = [
  { n: 'Messenger', s: svg(messenger) },
  { n: 'Slack', s: svg(slack) },
  { n: 'Notes', s: notes },
  { n: 'Mail', s: mail },
  { n: 'Chrome', s: svg(chrome) },
  { n: 'VS Code', s: svg(vscode) },
  { n: 'Notion', s: svg(notion) },
  { n: 'Figma', s: svg(figma) },
  { n: 'Discord', s: svg(discord) },
  { n: 'GitHub', s: svg(github) },
  { n: 'Linear', s: svg(linear) },
  { n: 'Spotify', s: svg(spotify) },
  { n: 'Zoom', s: svg(zoom) },
  { n: 'Telegram', s: svg(telegram) },
  { n: 'WhatsApp', s: svg(whatsapp) },
  { n: 'Messages', s: svg(imessage) },
  { n: 'Gmail', s: svg(gmail) },
  { n: 'Outlook', s: svg(outlook) },
  { n: 'Teams', s: svg(teams) },
  { n: 'Docs', s: svg(gdocs) },
  { n: 'Sheets', s: svg(gsheets) },
  { n: 'Slides', s: svg(gslides) },
  { n: 'Drive', s: svg(gdrive) },
  { n: 'Calendar', s: svg(gcal) },
  { n: 'Safari', s: svg(safari) },
  { n: 'Arc', s: svg(arc) },
  { n: 'Firefox', s: svg(firefox) },
  { n: 'Cursor', s: svg(cursor) },
  { n: 'Signal', s: svg(signal) },
  { n: 'Xcode', s: svg(xcode) },
  { n: 'Obsidian', s: svg(obsidian) },
  { n: 'Things', s: svg(things) },
  { n: 'Todoist', s: svg(todoist) },
  { n: 'Asana', s: svg(asana) },
  { n: 'Trello', s: svg(trello) },
  { n: 'Jira', s: svg(jira) },
  { n: 'Confluence', s: svg(confluence) },
  { n: 'ClickUp', s: svg(clickup) },
  { n: 'Airtable', s: svg(airtable) },
  { n: 'Miro', s: svg(miro) },
  { n: 'Loom', s: svg(loom) },
  { n: 'Canva', s: svg(canva) },
  { n: 'Instagram', s: svg(instagram) },
  { n: 'Photoshop', s: svg(photoshop) },
  { n: 'Illustrator', s: svg(illustrator) },
  { n: 'Raycast', s: svg(raycast) },
  { n: 'Alfred', s: svg(alfred) },
  { n: 'Warp', s: svg(warp) },
  { n: 'Dropbox', s: svg(dropbox) },
  { n: 'iCloud', s: svg(icloud) },
  { n: 'LinkedIn', s: svg(linkedin) },
  { n: 'X', s: svg(x) },
  { n: 'Reddit', s: svg(reddit) },
  { n: 'YouTube', s: svg(youtube) },
  { n: 'Claude', s: svg(claude) },
  { n: 'Word', s: svg(word) },
  { n: 'Excel', s: svg(excel) },
  { n: 'PowerPoint', s: svg(powerpoint) },
  { n: 'Grammarly', s: svg(grammarly) },
  { n: 'Spark', s: svg(spark) }
];

export const APP_ROWS = [
  APPS.slice(0, Math.ceil(APPS.length / 2)),
  APPS.slice(Math.ceil(APPS.length / 2))
];
