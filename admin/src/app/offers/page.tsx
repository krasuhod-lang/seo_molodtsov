"use client";
import {
  collection,
  deleteDoc,
  doc,
  onSnapshot,
  orderBy,
  query,
  setDoc,
  writeBatch,
} from "firebase/firestore";
import { ref as storageRef, uploadBytes, getDownloadURL } from "firebase/storage";
import { useEffect, useMemo, useState } from "react";
import { DragDropContext, Droppable, Draggable, type DropResult } from "@hello-pangea/dnd";

import { getFirebase } from "@/lib/firebase";
import { isValidHttpUrl, type Offer } from "@/lib/types";

type Form = Omit<Offer, "id" | "order"> & { id?: string };

const EMPTY_FORM: Form = {
  name: "",
  slogan: "",
  amount: 0,
  term: 0,
  age: "",
  logoUrl: "",
  url: "",
};

export default function OffersPage() {
  const { db, storage } = getFirebase();
  const [offers, setOffers] = useState<Offer[]>([]);
  const [editing, setEditing] = useState<Form | null>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const q = query(collection(db, "offers"), orderBy("order"));
    const unsub = onSnapshot(
      q,
      (snap) => {
        setOffers(
          snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Offer, "id">) })),
        );
        setLoading(false);
      },
      (e) => {
        setError(e.message);
        setLoading(false);
      },
    );
    return () => unsub();
  }, [db]);

  const validation = useMemo(() => {
    if (!editing) return null;
    const errs: Record<string, string> = {};
    if (!editing.name.trim()) errs.name = "Укажите название МФО";
    if (!Number.isFinite(editing.amount) || editing.amount < 0) errs.amount = "Сумма ≥ 0";
    if (!Number.isFinite(editing.term) || editing.term < 0) errs.term = "Срок ≥ 0";
    if (!editing.age.trim()) errs.age = "Укажите возраст";
    if (!isValidHttpUrl(editing.url)) errs.url = "Нужна корректная http(s)-ссылка";
    return errs;
  }, [editing]);

  async function save() {
    if (!editing || !validation || Object.keys(validation).length > 0) return;
    const id = editing.id ?? doc(collection(db, "offers")).id;
    const order = editing.id
      ? (offers.find((o) => o.id === editing.id)?.order ?? offers.length)
      : offers.length;
    const payload = {
      name: editing.name,
      slogan: editing.slogan,
      amount: editing.amount,
      term: editing.term,
      age: editing.age,
      logoUrl: editing.logoUrl,
      url: editing.url,
      order,
    };
    await setDoc(doc(db, "offers", id), payload);
    setEditing(null);
  }

  async function remove(id: string) {
    if (!confirm("Удалить оффер?")) return;
    await deleteDoc(doc(db, "offers", id));
  }

  async function uploadLogo(file: File) {
    if (!editing) return;
    setUploading(true);
    try {
      const path = `logos/${Date.now()}_${file.name}`;
      const r = storageRef(storage, path);
      await uploadBytes(r, file);
      const url = await getDownloadURL(r);
      setEditing({ ...editing, logoUrl: url });
    } finally {
      setUploading(false);
    }
  }

  async function onDragEnd(result: DropResult) {
    if (!result.destination) return;
    const reordered = Array.from(offers);
    const [moved] = reordered.splice(result.source.index, 1);
    reordered.splice(result.destination.index, 0, moved);
    setOffers(reordered);
    const batch = writeBatch(db);
    reordered.forEach((o, i) => batch.update(doc(db, "offers", o.id), { order: i }));
    await batch.commit();
  }

  return (
    <div>
      <header className="mb-4 flex items-center justify-between">
        <h1 className="text-2xl font-bold">Офферы</h1>
        <button onClick={() => setEditing({ ...EMPTY_FORM })} className="btn-primary">
          + Добавить оффер
        </button>
      </header>

      {error && <div className="card mb-4 text-sm text-red-600">{error}</div>}
      {loading ? (
        <div className="text-slate-500">Загрузка…</div>
      ) : offers.length === 0 ? (
        <div className="card text-center text-slate-500">
          Пока нет офферов. Нажмите «Добавить оффер».
        </div>
      ) : (
        <DragDropContext onDragEnd={onDragEnd}>
          <Droppable droppableId="offers">
            {(provided) => (
              <ul ref={provided.innerRef} {...provided.droppableProps} className="space-y-2">
                {offers.map((o, i) => (
                  <Draggable key={o.id} draggableId={o.id} index={i}>
                    {(p) => (
                      <li
                        ref={p.innerRef}
                        {...p.draggableProps}
                        className="card flex items-center gap-3"
                      >
                        <span
                          {...p.dragHandleProps}
                          className="cursor-grab select-none text-slate-400"
                          aria-label="Перетащить"
                        >
                          ⋮⋮
                        </span>
                        {o.logoUrl ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img
                            src={o.logoUrl}
                            alt=""
                            className="h-10 w-10 rounded-md object-cover"
                          />
                        ) : (
                          <div className="h-10 w-10 rounded-md bg-slate-100" />
                        )}
                        <div className="min-w-0 flex-1">
                          <div className="truncate font-semibold">{o.name}</div>
                          <div className="truncate text-xs text-slate-500">{o.slogan}</div>
                        </div>
                        <div className="text-sm text-slate-600">
                          {o.amount} ₽ · {o.term} дн. · {o.age}
                        </div>
                        <button
                          onClick={() => setEditing({ ...o })}
                          className="btn-ghost"
                        >
                          Изменить
                        </button>
                        <button onClick={() => remove(o.id)} className="btn-danger">
                          Удалить
                        </button>
                      </li>
                    )}
                  </Draggable>
                ))}
                {provided.placeholder}
              </ul>
            )}
          </Droppable>
        </DragDropContext>
      )}

      {editing && (
        <div
          className="fixed inset-0 z-40 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setEditing(null)}
        >
          <div
            className="card w-full max-w-lg space-y-3"
            onClick={(e) => e.stopPropagation()}
          >
            <h2 className="text-lg font-bold">
              {editing.id ? "Редактирование оффера" : "Новый оффер"}
            </h2>

            <Field label="Название МФО" error={validation?.name}>
              <input
                className="input"
                value={editing.name}
                onChange={(e) => setEditing({ ...editing, name: e.target.value })}
              />
            </Field>
            <Field label="Слоган">
              <input
                className="input"
                value={editing.slogan}
                onChange={(e) => setEditing({ ...editing, slogan: e.target.value })}
              />
            </Field>
            <div className="grid grid-cols-3 gap-3">
              <Field label="Сумма (₽)" error={validation?.amount}>
                <div className="relative">
                  <input
                    type="number"
                    min={0}
                    className="input pr-8"
                    value={editing.amount}
                    onChange={(e) => setEditing({ ...editing, amount: Number(e.target.value) })}
                  />
                  <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm text-slate-400">₽</span>
                </div>
              </Field>
              <Field label="Срок" error={validation?.term}>
                <div className="relative">
                  <input
                    type="number"
                    min={0}
                    className="input pr-10"
                    value={editing.term}
                    onChange={(e) => setEditing({ ...editing, term: Number(e.target.value) })}
                  />
                  <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm text-slate-400">дн.</span>
                </div>
              </Field>
              <Field label="Возраст" error={validation?.age}>
                <input
                  className="input"
                  placeholder="18-65"
                  value={editing.age}
                  onChange={(e) => setEditing({ ...editing, age: e.target.value })}
                />
              </Field>
            </div>
            <Field label="Логотип">
              <div className="flex items-center gap-3">
                {editing.logoUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={editing.logoUrl} alt="" className="h-12 w-12 rounded object-cover" />
                )}
                <input
                  type="file"
                  accept="image/*"
                  onChange={(e) => {
                    const f = e.target.files?.[0];
                    if (f) void uploadLogo(f);
                  }}
                />
                {uploading && <span className="text-xs text-slate-500">Загружаем…</span>}
              </div>
            </Field>
            <Field label="Ссылка на оффер" error={validation?.url}>
              <input
                type="url"
                className="input"
                placeholder="https://…"
                value={editing.url}
                onChange={(e) => setEditing({ ...editing, url: e.target.value })}
              />
            </Field>

            <div className="flex justify-end gap-2 pt-2">
              <button className="btn-ghost" onClick={() => setEditing(null)}>
                Отмена
              </button>
              <button
                className="btn-primary"
                onClick={save}
                disabled={!!(validation && Object.keys(validation).length > 0)}
              >
                Сохранить
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function Field({
  label,
  error,
  children,
}: {
  label: string;
  error?: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label className="label">{label}</label>
      {children}
      {error && <div className="mt-1 text-xs text-red-600">{error}</div>}
    </div>
  );
}
