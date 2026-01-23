# Atomo - Digital Services Platform

Atomo es una plataforma de servicios digitales diseñada para ofrecer una experiencia elegante, profesional y altamente personalizable para restaurantes y negocios gastronómicos.

## 🚀 Características Principales

- **Ecosistema Completo**:
  - **Digital Menu**: Cartas interactivas para restaurantes.
  - **Portfolio**: Galerías visuales para creativos.
  - **Shop**: Tiendas minimalistas con categorías y productos.
  - **CV**: Hojas de vida digitales profesionales.
  - **Invitations**: Invitaciones a eventos con RSVP.
- **Múltiples Plantillas Premium**: Diseños adaptables que se ajustan a la identidad de tu marca.
  - **Minimalist**: Limpio y enfocado en el contenido.
  - **Elegance**: Sofisticado y refinado.
  - **Modern**: Innovador y dinámico.
  - **Luxury**: Exclusivo y de alta gama.
  - **Cyber**: Futurista y tecnológico.
- **Gestión Intuitiva**: Integración con Supabase para una gestión de datos en tiempo real.
- **Optimización de Rendimiento**: Construido con Astro para tiempos de carga ultrarrápidos y excelente SEO.
- **Diseño Responsivo**: Experiencia de usuario impecable en dispositivos móviles y escritorio.

## 🛠️ Stack Tecnológico

- **Frontend**: [Astro](https://astro.build/) (v5)
- **Estilos**: [Tailwind CSS](https://tailwindcss.com/) (v4)
- **Base de Datos y Autenticación**: [Supabase](https://supabase.com/)
- **Despliegue**: [Cloudflare](https://www.cloudflare.com/)

## 📁 Estructura del Proyecto

```text
/
├── public/          # Activos estáticos
├── src/
│   ├── assets/      # Imágenes y recursos de diseño
│   ├── components/  # Componentes Astro reutilizables
│   │   └── templates/ # Diferentes diseños de menú
│   ├── data/        # Repositorios y lógica de acceso a datos
│   ├── domain/      # Modelos y lógica de negocio
│   ├── layouts/     # Estructuras de página base
│   ├── lib/         # Utilidades y configuración de clientes (Supabase)
│   ├── pages/       # Rutas y páginas de la aplicación
│   └── styles/      # Estilos globales y tokens de diseño
├── package.json
└── astro.config.mjs
```

## 🧞 Comandos

| Comando          | Acción                                                     |
| :--------------- | :--------------------------------------------------------- |
| `pnpm install`   | Instala las dependencias del proyecto                      |
| `pnpm dev`       | Inicia el servidor de desarrollo local en `localhost:4321` |
| `pnpm build`     | Compila el sitio para producción en `./dist/`              |
| `pnpm preview`   | Previsualiza la compilación localmente                     |
| `pnpm astro ...` | Ejecuta comandos de la CLI de Astro                        |

## ⚙️ Configuración

Para ejecutar este proyecto, necesitarás configurar las variables de entorno de Supabase en un archivo `.env`:

```sh
PUBLIC_SUPABASE_URL=tu_url_de_supabase
PUBLIC_SUPABASE_ANON_KEY=tu_anon_key_de_supabase
```

## 🌐 Despliegue en Cloudflare

Este proyecto está preconfigurado para desplegarse en **Cloudflare Pages**.

### Requisitos Previos

1. Tener una cuenta en [Cloudflare](https://dash.cloudflare.com/).
2. Tener instalado [Wrangler](https://developers.cloudflare.com/workers/wrangler/install-and-setup/) globalmente o usar `npx`.

### Pasos para Desplegar (Dashboard de Cloudflare)

1. **Conectar Repositorio**: En el dashboard de Cloudflare Pages, conecta tu repositorio de GitHub.
2. **Configuración de Build**:
   - **Framework Preset**: `Astro`
   - **Build Command**: `pnpm run build`
   - **Output directory**: `dist`
   - **Deploy command**: **DÉJALO VACÍO** (Importante: Cloudflare Pages despliega automáticamente el contenido de la carpeta `dist` tras el build).
3. **Variables de Entorno**: Ya las he configurado en `wrangler.toml`. Sin embargo, para mayor seguridad, puedes añadirlas también en el panel de Cloudflare Pages (Settings > Environment Variables) y borrar las de `wrangler.toml` si el repositorio es público.
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `NODE_VERSION`: `22`
4. **Despliegue Manual (Opcional)**:
   Si prefieres desplegar desde tu terminal:
   ```sh
   pnpm deploy
   ```

> [!IMPORTANT]
> El error `wrangler: not found` ocurría porque faltaba en las dependencias. Ya ha sido añadido. Si usas la integración de Git, asegúrate de que el "Deploy command" en Cloudflare esté vacío o configurado como el comando de build estándar.

---

Desarrollado con ❤️ por el equipo de **Atomo**.
