// shared open/close state for the download dialog
export const downloadDialog = $state({ open: false });

export function openDownloadDialog() {
  downloadDialog.open = true;
}

export function closeDownloadDialog() {
  downloadDialog.open = false;
}
