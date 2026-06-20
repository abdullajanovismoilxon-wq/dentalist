"use client";
import { useFavorites } from "@/hooks/useFavorites";
import { useAuthStore } from "@/stores/authStore";
import { DoctorGrid } from "@/components/doctors/DoctorGrid";
import { Button } from "@/components/ui/Button";
import { Heart } from "lucide-react";
import Link from "next/link";

export default function FavoritesPage() {
  const { data: favorites, isLoading } = useFavorites();
  const user = useAuthStore((s) => s.user);

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Heart className="w-16 h-16 text-text-secondary/30 mb-4" />
        <p className="text-text-secondary mb-4">Sevimlilarni ko'rish uchun kiring</p>
        <Link href="/auth/login"><Button>Kirish</Button></Link>
      </div>
    );
  }

  return (
    <div className="px-4 pt-4 pb-4 space-y-4">
      <h1 className="text-lg font-bold">Sevimli shifokorlar</h1>
      <DoctorGrid doctors={favorites?.map((f) => f.doctor_detail) || []} loading={isLoading} />
      {!isLoading && !favorites?.length && (
        <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
          <Heart className="w-12 h-12 mb-3 opacity-30" />
          <p className="text-sm">Sevimli shifokorlar yo'q</p>
          <Link href="/" className="text-primary text-sm mt-2 font-medium">Shifokor qidirish</Link>
        </div>
      )}
    </div>
  );
}
