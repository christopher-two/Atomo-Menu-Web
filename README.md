# Atomo Menu - Digital Menu Solution

Atomo Menu es una plataforma de menú digital diseñada para ofrecer una experiencia elegante, profesional y altamente personalizable para restaurantes y negocios gastronómicos.

## 🚀 Características Principales

- **Múltiples Plantillas Premium**: Diseños adaptables que se ajustan a la identidad de tu marca.
  - **Minimalist**: Limpio y enfocado en el contenido.
  - **Elegance**: Sofisticado y refinado.
  - **Modern**: Innovador y dinámico.
  - **Luxury**: Exclusivo y de alta gama.
  - **Cyber**: Futurista y tecnológico.
- **Gestión Intuitiva**: Integración con Supabase para una gestión de datos en tiempo real.
- **Optimización de Rendimiento**: Construido con Astro para tiempos de carga ultrarrápidos y excelente SEO.
- **Diseño Responsivo**: Experiencia de usuario impecable en dispositivos móviles y escritorio.
- **Caché Inteligente**: Estrategia de caché en el borde para una respuesta instantánea.

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

| Comando | Acción |
| :--- | :--- |
| `pnpm install` | Instala las dependencias del proyecto |
| `pnpm dev` | Inicia el servidor de desarrollo local en `localhost:4321` |
| `pnpm build` | Compila el sitio para producción en `./dist/` |
| `pnpm preview` | Previsualiza la compilación localmente |
| `pnpm astro ...` | Ejecuta comandos de la CLI de Astro |

## ⚙️ Configuración

Para ejecutar este proyecto, necesitarás configurar las variables de entorno de Supabase en un archivo `.env`:

```sh
PUBLIC_SUPABASE_URL=tu_url_de_supabase
PUBLIC_SUPABASE_ANON_KEY=tu_anon_key_de_supabase
```

---
Desarrollado con ❤️ por el equipo de **Atomo Menu**.
