/* shared state for the /enterprise & /education pitch bot.
   any "book a call"-style CTA calls pitch.show(); the bot pops
   open and gently explains that everything is free. */
export const pitch = $state({
  open: false,
  show() {},
});
