export type Offer = {
  id: string;
  name: string;
  slogan: string;
  amount: number;
  term: number;
  age: string;
  logoUrl: string;
  url: string;
  order: number;
};

export type OnboardingSlide = { title: string; text: string };

export type AppContent = {
  homeTitle: string;
  homeSubtitle: string;
  ratingTitle: string;
  ratingSubtitle: string;
  contactsText: string;
  onboarding: OnboardingSlide[];
};

export const DEFAULT_CONTENT: AppContent = {
  homeTitle: "Займы 24/7",
  homeSubtitle: "На вашу банковскую карту, с любой кредитной историей",
  ratingTitle: "Рейтинг МФО",
  ratingSubtitle: "Рейтинг составлен на основе отзывов из открытых источников",
  contactsText:
    "По всем вопросам, связанным с работой приложения, можно связаться с нами по e-mail:\navada-gorup@yandex.ru\n\nСервис не предоставляет займы и не является кредитной организацией.",
  onboarding: [
    { title: "Деньги онлайн на карту", text: "Оформите заявку на займ 3-5 компаниях и получите максимальный шанс одобрения" },
    { title: "Первый займ бесплатно", text: "Для новых клиентов компаний-партнеров" },
    { title: "На связи 24/7", text: "Заявки рассматриваются круглосуточно, без выходных" },
  ],
};

/** http(s) URL валидация — для поля «Ссылка на оффер». */
export function isValidHttpUrl(value: string): boolean {
  try {
    const u = new URL(value);
    return u.protocol === "http:" || u.protocol === "https:";
  } catch {
    return false;
  }
}
