import type { Metadata } from "next";
import type { ReactNode } from "react";

import "./globals.css";
import { AuthProvider } from "@/lib/auth";
import { Shell } from "@/components/Shell";

export const metadata: Metadata = {
  title: "Займы 24/7 — админка",
  description: "Управление офферами и контентом приложения «Займы 24/7»",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ru">
      <body>
        <AuthProvider>
          <Shell>{children}</Shell>
        </AuthProvider>
      </body>
    </html>
  );
}
