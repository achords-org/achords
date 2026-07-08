// ══════════════════════════════════════════════════════════════════════
// i18n — Translations for ES/EN
// ══════════════════════════════════════════════════════════════════════

export const translations = {
  es: {
    // Nav
    nav: {
      home: "Inicio",
      products: "Productos",
      docs: "Docs",
      blog: "Blog",
      license: "Licencia",
      getStarted: "Comenzar",
    },
    // Hero
    hero: {
      title1: "LA ARMONÍA",
      title2: "DE LA IA.",
      subtitle: "Diseñado para equipos de desarrollo que migran a sistemas de agentes. Orquestación de precisión para transformar flujos de trabajo en sinfonías automatizadas de código.",
      starGitHub: "Star on GitHub",
      docs: "Documentación →",
      terminal: "Terminal",
      command: "npx achords obase",
    },
    // Products
    products: {
      obase: {
        name: "Organization Base",
        desc: "Inicializa tu organización GitHub para desarrollo multi-agente.",
        status: null, // null = available
      },
      rcord: {
        name: "Repository Coordination",
        desc: "Coordinación basada en claims para agentes en el mismo repo.",
        status: "Próximamente",
      },
      iaci: {
        name: "IA on CI",
        desc: "Revisiones automáticas de código con IA en CI/CD.",
        status: "Próximamente",
      },
      kbweb: {
        name: "KB Web",
        desc: "Documentación viva compatible con Obsidian.",
        status: "Próximamente",
      },
    },
    // Features
    features: {
      title: "FEATURES.",
      subtitle: "Ocho características fundamentales para la orquestación técnica de tu ecosistema de agentes, combinando potencia organizacional con flexibilidad de despliegue.",
      items: [
        { num: "01", title: "Bases de Organización", desc: "Gestión de recursos maestros y orquestación centralizada de activos digitales." },
        { num: "02", title: "Coordinación Git", desc: "Sincronía multi-hilo para repositorios complejos con resolución de conflictos asistida." },
        { num: "03", title: "IA en CI", desc: "Revisiones automáticas de código y validación de lógica de negocio en tiempo real." },
        { num: "04", title: "KB Web", desc: "Documentación viva y dinámica que evoluciona con cada commit del equipo." },
        { num: "05", title: "Documentación para Humanos y Agentes", desc: "Diseñada para ser consumida tanto por desarrolladores como por LLMs de última generación." },
        { num: "06", title: "Self-hosted y Nube Opcional", desc: "Opciones de despliegue flexibles con control total on-premise o escalabilidad gestionada." },
        { num: "07", title: "Memoria Organizacional y RBAC", desc: "Base de conocimientos sincronizada con políticas robustas de Control de Acceso Basado en Roles." },
        { num: "08", title: "Skill Hub", desc: "Un mercado centralizado para habilidades de agentes, organizado por equipos y perfiles." },
      ],
    },
    // Terminal
    terminal: {
      title: "Estética del código.",
      feature1: {
        title: "Despliegue Instantáneo",
        desc: "Integración nativa en terminal. Sin sobrecarga de configuración.",
      },
      feature2: {
        title: "Privacidad Cifrada",
        desc: "Sincronización de conocimiento bajo protocolos de seguridad máxima.",
      },
      command1: "achords init --composition=master",
      status1: "... inicializando motor armónico",
      status2: "... escaneando repositorios [██████████] 100%",
      ready: "achords status --ready",
      readyText: "4 agentes listos para la orquestación autónoma.",
    },
    // Footer
    footer: {
      copyright: "© 2026 Achords. Todos los derechos reservados. Inteligencia rítmica para el desarrollo de vanguardia.",
      product: { title: "Producto", items: ["Funciones", "Seguridad", "Roadmap"] },
      resources: { title: "Recursos", items: ["Documentación", "GitHub", "Manifiesto"] },
      community: { title: "Comunidad", items: ["GitHub Issues", "Discord"] },
      legal: { title: "Legal", items: ["Privacidad", "Términos"] },
    },
  },

  en: {
    // Nav
    nav: {
      home: "Home",
      products: "Products",
      docs: "Docs",
      blog: "Blog",
      license: "License",
      getStarted: "Get Started",
    },
    // Hero
    hero: {
      title1: "THE HARMONY",
      title2: "OF AI.",
      subtitle: "Designed for development teams migrating to agent systems. Precision orchestration to transform workflows into automated code symphonies.",
      starGitHub: "Star on GitHub",
      docs: "Documentation →",
      terminal: "Terminal",
      command: "npx achords obase",
    },
    // Products
    products: {
      obase: {
        name: "Organization Base",
        desc: "Initialize your GitHub organization for multi-agent development.",
        status: null,
      },
      rcord: {
        name: "Repository Coordination",
        desc: "Claim-based agent coordination within the same repo.",
        status: "Coming soon",
      },
      iaci: {
        name: "IA on CI",
        desc: "Automated AI-powered code reviews in CI/CD.",
        status: "Coming soon",
      },
      kbweb: {
        name: "KB Web",
        desc: "Obsidian-compatible living documentation.",
        status: "Coming soon",
      },
    },
    // Features
    features: {
      title: "FEATURES.",
      subtitle: "Eight fundamental features for the technical orchestration of your agent ecosystem, combining organizational power with deployment flexibility.",
      items: [
        { num: "01", title: "Organization Base", desc: "Master resource management and centralized digital asset orchestration." },
        { num: "02", title: "Git Coordination", desc: "Multi-threaded sync for complex repositories with assisted conflict resolution." },
        { num: "03", title: "IA on CI", desc: "Automated code reviews and real-time business logic validation." },
        { num: "04", title: "KB Web", desc: "Living documentation that evolves with every team commit." },
        { num: "05", title: "Docs for Humans & Agents", desc: "Designed to be consumed by both developers and cutting-edge LLMs." },
        { num: "06", title: "Self-hosted & Optional Cloud", desc: "Flexible deployment options with full on-premise control or managed scalability." },
        { num: "07", title: "Organizational Memory & RBAC", desc: "Knowledge base synchronized with robust Role-Based Access Control policies." },
        { num: "08", title: "Skill Hub", desc: "A centralized marketplace for agent skills, organized by teams and profiles." },
      ],
    },
    // Terminal
    terminal: {
      title: "The aesthetics of code.",
      feature1: {
        title: "Instant Deployment",
        desc: "Native terminal integration. No configuration overhead.",
      },
      feature2: {
        title: "Encrypted Privacy",
        desc: "Knowledge synchronization under maximum security protocols.",
      },
      command1: "achords init --composition=master",
      status1: "... initializing harmonic engine",
      status2: "... scanning repositories [██████████] 100%",
      ready: "achords status --ready",
      readyText: "4 agents ready for autonomous orchestration.",
    },
    // Footer
    footer: {
      copyright: "© 2026 Achords. All rights reserved. Rhythmic intelligence for cutting-edge development.",
      product: { title: "Product", items: ["Features", "Security", "Roadmap"] },
      resources: { title: "Resources", items: ["Documentation", "GitHub", "Manifesto"] },
      community: { title: "Community", items: ["GitHub Issues", "Discord"] },
      legal: { title: "Legal", items: ["Privacy", "Terms"] },
    },
  },
}

// Language manager
let currentLang = localStorage.getItem('achords-lang') || 'es'

export function setLang(lang) {
  currentLang = lang
  localStorage.setItem('achords-lang', lang)
  document.documentElement.lang = lang
  updateUI()
}

export function getLang() {
  return currentLang
}

export function t(key) {
  const keys = key.split('.')
  let value = translations[currentLang]
  for (const k of keys) {
    value = value?.[k]
  }
  return value || key
}

// Update all elements with data-i18n attribute
function updateUI() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n')
    el.textContent = t(key)
  })
  document.querySelectorAll('[data-i18n-html]').forEach(el => {
    const key = el.getAttribute('data-i18n-html')
    el.innerHTML = t(key)
  })
  // Update lang toggle active state
  document.querySelectorAll('.lang-btn').forEach(btn => {
    const lang = btn.dataset.lang
    btn.classList.toggle('text-white', lang === currentLang)
    btn.classList.toggle('text-zinc-600', lang !== currentLang)
  })
}
