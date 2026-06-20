"use client";
import { useRef, useState, useEffect } from "react";
import { useProfile, useUpdateProfile } from "@/hooks/useAuth";
import { useFavorites } from "@/hooks/useFavorites";
import { useMyAppointments } from "@/hooks/useAppointments";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { useForm } from "react-hook-form";
import { User, Calendar, Heart, Droplets, AlertTriangle, Star, ChevronRight, Camera } from "lucide-react";
import Link from "next/link";
import { formatRating } from "@/utils";
import api from "@/services/api";

export default function ProfilePage() {
  const [mounted, setMounted] = useState(false);
  useEffect(() => { setMounted(true); }, []);
  const { data: user, isLoading, refetch } = useProfile();
  const updateProfile = useUpdateProfile();
  const { data: favorites } = useFavorites();
  const { data: appointments } = useMyAppointments();
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    const formData = new FormData();
    formData.append("avatar", file);
    try {
      await api.patch("/users/profile/", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      refetch();
    } catch {}
    e.target.value = "";
  };

  const handleAvatarDelete = async () => {
    if (!confirm("Rasmni o'chirishni xohlaysizmi?")) return;
    try {
      await api.patch("/users/profile/", { avatar: null });
      refetch();
    } catch {}
  };

  const { register, handleSubmit } = useForm({
    values: user ? {
      first_name: user.first_name || "",
      last_name: user.last_name || "",
      email: user.email || "",
      blood_group: user.blood_group || "",
      allergies: user.allergies || "",
      gender: user.gender || "",
    } : undefined,
  });

  if (isLoading || !mounted) {
    return (
      <div className="animate-pulse px-4 pt-6 space-y-4">
        <div className="flex items-center gap-4">
          <div className="w-20 h-20 rounded-2xl bg-gray-200" />
          <div className="space-y-2">
            <div className="h-5 bg-gray-200 rounded w-32" />
            <div className="h-3 bg-gray-200 rounded w-24" />
          </div>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <User className="w-16 h-16 text-text-secondary/30 mb-4" />
        <p className="text-text-secondary mb-4">Profilni ko'rish uchun kiring</p>
        <Link href="/auth/login">
          <Button>Kirish</Button>
        </Link>
      </div>
    );
  }

  const menuItems = [
    { icon: Droplets, label: "Qon guruhi", value: user.blood_group || "Ko'rsatilmagan" },
    { icon: AlertTriangle, label: "Allergiyalar", value: user.allergies || "Yo'q" },
    { icon: Calendar, label: "Qabullar", value: `${appointments?.filter(a => a.status !== "cancelled").length || 0} ta`, href: "/appointments" },
    { icon: Heart, label: "Sevimlilar", value: `${favorites?.length || 0} ta`, href: "/favorites" },
    { icon: Star, label: "Reyting", value: user.role === "doctor" ? "4.5" : "—" },
  ];

  return (
    <div className="max-w-2xl mx-auto px-4 pt-4 pb-4 space-y-4">
      {/* Profile Header */}
      <div className="bg-gradient-to-br from-primary-light via-primary/5 to-secondary/10 rounded-3xl p-6 -mx-4 px-4">
        <div className="flex items-center gap-4">
          <div className="relative group">
            <div className="w-20 h-20 rounded-2xl bg-surface shadow-sm flex items-center justify-center overflow-hidden flex-shrink-0">
              {user.avatar ? (
                <img src={user.avatar} alt="" className="w-full h-full object-cover" />
              ) : (
                <User className="w-8 h-8 text-primary" />
              )}
            </div>
            <div className="absolute -bottom-1 -right-1 flex gap-1">
              <button
                onClick={() => avatarInputRef.current?.click()}
                className="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center shadow-md hover:bg-primary-dark transition-colors"
              >
                <Camera className="w-3.5 h-3.5" />
              </button>
              {user.avatar && (
                <button
                  onClick={handleAvatarDelete}
                  className="w-7 h-7 rounded-full bg-danger text-white flex items-center justify-center shadow-md hover:bg-red-600 transition-colors"
                >
                  <span className="text-xs font-bold">×</span>
                </button>
              )}
            </div>
            <input
              ref={avatarInputRef}
              type="file"
              accept="image/*"
              onChange={handleAvatarUpload}
              className="hidden"
            />
          </div>
          <div className="flex-1 min-w-0">
            <h1 className="text-lg font-bold">{user.first_name} {user.last_name}</h1>
            <p className="text-sm text-text-secondary">{user.phone}</p>
            <Badge variant="primary" className="mt-1">{user.role === "doctor" ? "Shifokor" : "Bemor"}</Badge>
          </div>
        </div>
      </div>

      {/* Info Cards */}
      <div className="grid grid-cols-2 gap-3">
        {menuItems.slice(0, 2).map((item) => (
          <Card key={item.label}>
            <CardContent className="p-3">
              <div className="flex items-center gap-2 mb-1">
                <item.icon className="w-4 h-4 text-primary" />
                <span className="text-xs text-text-secondary">{item.label}</span>
              </div>
              <p className="text-sm font-medium">{item.value}</p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Menu Links */}
      <div className="bg-surface rounded-2xl border border-border divide-y divide-border">
        {menuItems.slice(2).map((item) => (
          item.href ? (
            <Link key={item.label} href={item.href} className="flex items-center justify-between p-4 hover:bg-bg transition-colors">
              <div className="flex items-center gap-3">
                <item.icon className="w-5 h-5 text-primary" />
                <div>
                  <p className="text-sm font-medium">{item.label}</p>
                  <p className="text-xs text-text-secondary">{item.value}</p>
                </div>
              </div>
              <ChevronRight className="w-4 h-4 text-text-secondary" />
            </Link>
          ) : (
            <div key={item.label} className="flex items-center justify-between p-4">
              <div className="flex items-center gap-3">
                <item.icon className="w-5 h-5 text-primary" />
                <div>
                  <p className="text-sm font-medium">{item.label}</p>
                  <p className="text-xs text-text-secondary">{item.value}</p>
                </div>
              </div>
            </div>
          )
        ))}
      </div>

      {/* Edit Form */}
      <h2 className="font-semibold text-base pt-2">Shaxsiy ma'lumotlar</h2>
      <form onSubmit={handleSubmit((data) => updateProfile.mutate(data))} className="space-y-3">
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1">
            <label className="text-xs font-medium text-text-secondary">Ism</label>
            <input {...register("first_name")} className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary" />
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-text-secondary">Familiya</label>
            <input {...register("last_name")} className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary" />
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div className="space-y-1">
            <label className="text-xs font-medium text-text-secondary">Qon guruhi</label>
            <select {...register("blood_group")} className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary bg-surface">
              <option value="">Tanlang</option>
              {["I+", "I-", "II+", "II-", "III+", "III-", "IV+", "IV-"].map((bg) => (
                <option key={bg} value={bg}>{bg}</option>
              ))}
            </select>
          </div>
          <div className="space-y-1">
            <label className="text-xs font-medium text-text-secondary">Jins</label>
            <select {...register("gender")} className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary bg-surface">
              <option value="">Tanlang</option>
              <option value="male">Erkak</option>
              <option value="female">Ayol</option>
            </select>
          </div>
        </div>
        <div className="space-y-1">
          <label className="text-xs font-medium text-text-secondary">Allergiyalar</label>
          <input {...register("allergies")} placeholder="Agar mavjud bo'lsa" className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary" />
        </div>
        <Button type="submit" className="w-full" loading={updateProfile.isPending}>Saqlash</Button>
      </form>
    </div>
  );
}
