<script>
  import Logo from './Logo.svelte';

  let {
    variant = 'personal',
    logoSize = 24,
    logoColor = null,
    personalHref = '/',
  } = $props();

  const VARIANTS = [
    {
      id: 'personal',
      href: personalHref,
      label: 'Personal',
      desc: 'Everyday dictation, free forever',
    },
    {
      id: 'education',
      href: '/education',
      label: 'Education',
      desc: 'K-12 & higher ed',
    },
    {
      id: 'enterprise',
      href: '/enterprise',
      label: 'Enterprise',
      desc: 'Fleet deployments',
    },
  ];

  const current = $derived(
    VARIANTS.find((v) => v.id === variant) ?? VARIANTS[0]
  );

  let open = $state(false);
  let root = $state(null);

  function toggle() {
    open = !open;
  }

  function close() {
    open = false;
  }

  /* click-outside to close: pointerdown listener, added only while open */
  $effect(() => {
    if (!open) return;
    const onDoc = (e) => {
      if (root && !root.contains(e.target)) open = false;
    };
    document.addEventListener('pointerdown', onDoc);
    return () => document.removeEventListener('pointerdown', onDoc);
  });

  function onKey(e) {
    if (e.key === 'Escape') open = false;
  }
</script>

<svelte:window onkeydown={onKey} />

<div
  class="vn"
  bind:this={root}
>
  <a
    href={current.href}
    class="vn-logo"
    aria-label={'typie ' + current.id + ' home'}
  >
    <Logo
      size={logoSize}
      color={logoColor}
    />
  </a>

  <span
    class="vn-divider"
    aria-hidden="true"
  ></span>

  <button
    class="vn-trigger"
    class:open
    onclick={toggle}
    aria-expanded={open}
    aria-haspopup="menu"
    aria-label={'typie ' + current.id + ' — switch edition'}
  >
    {current.id}
    <svg
      class="chev"
      viewBox="0 0 10 6"
      aria-hidden="true"
    >
      <path
        d="M1 1l4 4 4-4"
        fill="none"
        stroke="currentColor"
        stroke-width="1.6"
        stroke-linecap="round"
        stroke-linejoin="round"
      />
    </svg>
  </button>

  {#if open}
    <div
      class="vn-menu"
      role="menu"
    >
      {#each VARIANTS as v (v.id)}
        <a
          role="menuitem"
          href={v.href}
          class="vn-item"
          class:current={v.id === variant}
          onclick={close}
        >
          <span class="vn-item-txt">
            <b>{v.label}</b>
            <span>{v.desc}</span>
          </span>
          <i
            class="vn-dot"
            aria-hidden="true"
          ></i>
        </a>
      {/each}
    </div>
  {/if}
</div>

<style>
  .vn {
    position: relative;
    display: inline-flex;
    align-items: center;
    gap: 12px;
  }

  .vn-logo {
    display: inline-flex;
    line-height: 0;
  }

  .vn-divider {
    width: 1px;
    height: 18px;
    background: currentColor;
    opacity: 0.18;
  }

  .vn-trigger {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 8px;
    margin: -6px -8px;
    background: none;
    border: 0;
    border-radius: 8px;
    cursor: pointer;
    font-family: var(--mono, ui-monospace, monospace);
    font-size: 0.68rem;
    letter-spacing: 0.18em;
    text-transform: uppercase;
    color: var(--vn-fg, inherit);
    transition: color 160ms var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1));
  }

  .vn-trigger:hover,
  .vn-trigger.open {
    color: var(--vn-accent, inherit);
  }

  .chev {
    width: 9px;
    height: 6px;
    transition: transform 220ms var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1));
  }

  .chev.open {
    transform: rotate(180deg);
  }

  .vn-menu {
    position: absolute;
    top: calc(100% + 12px);
    left: 0;
    z-index: 130;
    min-width: 250px;
    padding: 6px;
    background: var(--vn-menu-bg, #fff);
    border: 1px solid var(--vn-menu-border, rgba(19, 23, 34, 0.1));
    border-radius: 14px;
    box-shadow: var(--vn-menu-shadow, 0 18px 44px rgba(19, 23, 34, 0.18));
    transform-origin: top left;
    animation: vnPop 260ms var(--ease-out, cubic-bezier(0.16, 1, 0.3, 1)) both;
  }

  @keyframes vnPop {
    from {
      opacity: 0;
      transform: translateY(-6px) scale(0.97);
      filter: blur(4px);
    }
    to {
      opacity: 1;
      transform: none;
      filter: blur(0);
    }
  }

  .vn-item {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    padding: 10px 12px;
    border-radius: 9px;
    text-decoration: none;
    transition: background-color 160ms
      var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1));
  }

  .vn-item:hover {
    background: var(--vn-item-hover, rgba(19, 23, 34, 0.05));
  }

  .vn-item-txt {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .vn-item b {
    font-size: 0.875rem;
    font-weight: 700;
    color: var(--vn-item-fg, var(--ink, var(--ink-app)));
    transition: color 160ms var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1));
  }

  .vn-item span {
    font-size: 0.75rem;
    color: var(--vn-item-muted, rgba(19, 23, 34, 0.55));
  }

  .vn-item.current b {
    color: var(--vn-accent, var(--hotpink, var(--hotpink)));
  }

  .vn-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--vn-accent, var(--hotpink, var(--hotpink)));
    opacity: 0;
    transform: scale(0.5);
    transition:
      opacity 200ms var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1)),
      transform 200ms var(--ease-snap, cubic-bezier(0.22, 1, 0.36, 1));
  }

  .vn-item.current .vn-dot {
    opacity: 1;
    transform: none;
  }

  @media (prefers-reduced-motion: reduce) {
    .vn-menu {
      animation: none;
    }
    .chev {
      transition: none;
    }
  }
</style>
