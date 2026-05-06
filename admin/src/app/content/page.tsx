"use client";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { useEffect, useState } from "react";

import { getFirebase } from "@/lib/firebase";
import { DEFAULT_CONTENT, type AppContent } from "@/lib/types";

export default function ContentPage() {
  const { db } = getFirebase();
  const [content, setContent] = useState<AppContent>(DEFAULT_CONTENT);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savedAt, setSavedAt] = useState<Date | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const snap = await getDoc(doc(db, "content", "app"));
        if (snap.exists()) {
          setContent({ ...DEFAULT_CONTENT, ...(snap.data() as AppContent) });
        }
      } catch (e) {
        setError(e instanceof Error ? e.message : "Ошибка загрузки");
      } finally {
        setLoading(false);
      }
    })();
  }, [db]);

  async function save() {
    if (content.onboarding.some((s) => !s.title.trim() || !s.text.trim())) {
      setError("Заполните заголовок и текст для каждого слайда onboarding");
      return;
    }
    if (!content.contactsText.trim()) {
      setError("Текст контактов не должен быть пустым");
      return;
    }
    setSaving(true);
    setError(null);
    try {
      await setDoc(doc(db, "content", "app"), content);
      setSavedAt(new Date());
    } catch (e) {
      setSavedAt(null);
      setError(e instanceof Error ? e.message : "Ошибка сохранения");
    } finally {
      setSaving(false);
    }
  }

  function setSlide(i: number, patch: Partial<AppContent["onboarding"][number]>) {
    const next = content.onboarding.slice();
    next[i] = { ...next[i], ...patch };
    setContent({ ...content, onboarding: next });
  }

  if (loading) return <div className="text-slate-500">Загрузка…</div>;

  return (
    <div className="max-w-3xl space-y-6">
      <header className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Контент</h1>
        <div className="flex items-center gap-3">
          {savedAt && (
            <span className="text-xs text-slate-500">
              Сохранено в {savedAt.toLocaleTimeString("ru-RU")}
            </span>
          )}
          <button onClick={save} disabled={saving} className="btn-primary">
            {saving ? "Сохраняем…" : "Сохранить"}
          </button>
        </div>
      </header>

      {error && <div className="card text-sm text-red-600">{error}</div>}

      <section className="card space-y-3">
        <h2 className="font-semibold">Главная страница</h2>
        <Input
          label="Заголовок"
          value={content.homeTitle}
          onChange={(v) => setContent({ ...content, homeTitle: v })}
        />
        <Input
          label="Подзаголовок"
          value={content.homeSubtitle}
          onChange={(v) => setContent({ ...content, homeSubtitle: v })}
        />
      </section>

      <section className="card space-y-3">
        <h2 className="font-semibold">Рейтинг МФО</h2>
        <Input
          label="Заголовок"
          value={content.ratingTitle}
          onChange={(v) => setContent({ ...content, ratingTitle: v })}
        />
        <Input
          label="Подзаголовок"
          value={content.ratingSubtitle}
          onChange={(v) => setContent({ ...content, ratingSubtitle: v })}
        />
      </section>

      <section className="card space-y-3">
        <h2 className="font-semibold">Onboarding-слайды</h2>
        {content.onboarding.map((s, i) => (
          <div key={i} className="rounded-md border border-slate-200 p-3">
            <div className="mb-2 text-xs font-medium text-slate-500">Слайд {i + 1}</div>
            <Input
              label="Заголовок"
              value={s.title}
              onChange={(v) => setSlide(i, { title: v })}
            />
            <Textarea
              label="Текст"
              value={s.text}
              onChange={(v) => setSlide(i, { text: v })}
            />
          </div>
        ))}
      </section>

      <section className="card space-y-3">
        <h2 className="font-semibold">Контакты</h2>
        <Textarea
          label="Текст страницы"
          rows={8}
          value={content.contactsText}
          onChange={(v) => setContent({ ...content, contactsText: v })}
        />
      </section>
    </div>
  );
}

function Input({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="label">{label}</label>
      <input className="input" value={value} onChange={(e) => onChange(e.target.value)} />
    </div>
  );
}

function Textarea({
  label,
  value,
  onChange,
  rows = 3,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  rows?: number;
}) {
  return (
    <div>
      <label className="label">{label}</label>
      <textarea
        className="input"
        rows={rows}
        value={value}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}
