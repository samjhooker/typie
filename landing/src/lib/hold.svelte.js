export const hold = $state({
  press() {},
  /* true while a user-initiated hold is live - drives the blah word pops */
  demoing: false,
});
