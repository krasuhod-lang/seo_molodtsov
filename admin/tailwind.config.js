/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: "#2E7D32",
          dark: "#1B5E20",
          light: "#A5D6A7",
        },
      },
    },
  },
  plugins: [],
};
