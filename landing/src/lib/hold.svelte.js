export const hold = $state({
  press() {},
  /* true while a user-initiated hold is live - drives the blah demo (audio + word pops) */
  demoing: false
});
