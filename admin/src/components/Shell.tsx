"use client";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, type ReactNode } from "react";

import { useAuth } from "@/lib/auth";

const NAV = [
  { href: "/offers", label: "Офферы" },
  { href: "/content", label: "Контент" },
];

export function Shell({ children }: { children: ReactNode }) {
  const { user, loading, signOutUser } = useAuth();
  const pathname = usePathname();
  const router = useRouter();
  const isLogin = pathname === "/login";

  useEffect(() => {
    if (loading) return;
    if (!user && !isLogin) router.replace("/login");
    if (user && isLogin) router.replace("/offers");
  }, [user, loading, isLogin, router]);

  if (loading) {
    return <div className="flex h-screen items-center justify-center text-slate-500">Загрузка…</div>;
  }

  if (isLogin) return <>{children}</>;
  if (!user) return null;

  return (
    <div className="flex min-h-screen">
      <aside className="w-56 shrink-0 border-r border-slate-200 bg-white p-4">
        <div className="mb-6">
          <div className="text-base font-bold text-brand">Займы 24/7</div>
          <div className="text-xs text-slate-500">Админка</div>
        </div>
        <nav className="space-y-1">
          {NAV.map((n) => {
            const active = pathname?.startsWith(n.href);
            return (
              <Link
                key={n.href}
                href={n.href}
                className={`block rounded-md px-3 py-2 text-sm ${
                  active ? "bg-brand text-white" : "text-slate-700 hover:bg-slate-100"
                }`}
              >
                {n.label}
              </Link>
            );
          })}
        </nav>
        <div className="mt-8 border-t border-slate-200 pt-4">
          <div className="mb-2 truncate text-xs text-slate-500">{user.email}</div>
          <button onClick={signOutUser} className="btn-ghost w-full">
            Выйти
          </button>
        </div>
      </aside>
      <main className="flex-1 p-6">{children}</main>
    </div>
  );
}
