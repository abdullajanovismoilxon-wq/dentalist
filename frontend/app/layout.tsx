import type { Metadata, Viewport } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "Dentalist - Shifokor topish",
  description: "Eng yaqin stomatologlarni toping, reytingini ko'ring va onlayn yoziling",
  manifest: "/manifest.json",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  themeColor: "#00B5D8",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="uz">
      <body className="min-h-dvh bg-bg text-text antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
