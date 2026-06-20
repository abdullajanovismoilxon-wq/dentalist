"use client";
import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useRegisterDoctor } from "@/hooks/useAuth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Card, CardContent } from "@/components/ui/Card";
import { Stethoscope } from "lucide-react";
import dynamic from "next/dynamic";

const LocationPicker = dynamic(() => import("@/components/map/LocationPicker"), {
  ssr: false,
  loading: () => (
    <div className="w-full h-56 rounded-2xl bg-bg animate-pulse flex items-center justify-center">
      <Stethoscope className="w-6 h-6 text-text-secondary/30" />
    </div>
  ),
});

const schema = z
  .object({
    first_name: z.string().min(1, "Ism kiritilishi shart"),
    last_name: z.string().min(1, "Familiya kiritilishi shart"),
    phone: z.string().min(7, "Telefon raqam noto'g'ri"),
    password: z.string().min(8, "Kamida 8 ta belgi"),
    password2: z.string().min(8, "Parolni tasdiqlang"),
    gender: z.string().min(1, "Jinsni tanlang"),
    experience_years: z.coerce.number().min(0, "Tajriba yili noto'g'ri"),
    clinic_name: z.string().min(1, "Klinika nomi kiritilishi shart"),
    specializations: z.string().optional(),
    patient_type: z.string().optional(),
  })
  .refine((d) => d.password === d.password2, {
    message: "Parollar mos kelmadi",
    path: ["password2"],
  });

type FormData = z.infer<typeof schema>;

export default function DoctorRegisterPage() {
  const registerMutation = useRegisterDoctor();
  const [error, setError] = useState("");
  const [location, setLocation] = useState<{
    latitude: string;
    longitude: string;
    formatted_address: string;
  } | null>(null);
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    setError("");
    if (!location) {
      setError("Iltimos, xaritada klinika joylashuvini belgilang");
      return;
    }
    try {
      const payload = {
        ...data,
        ...location,
        specializations: data.specializations ? data.specializations.split(",").map((s) => s.trim()) : [],
      };
      await registerMutation.mutateAsync(payload as unknown as Record<string, unknown>);
    } catch (err: unknown) {
      const resp = (err as { response?: { data?: { errors?: Array<Record<string, string>> } } })?.response?.data;
      const msgs = resp?.errors;
      if (msgs?.length) {
        setError(Object.values(msgs[0])[0]);
      } else {
        setError("Ro'yxatdan o'tishda xatolik yuz berdi");
      }
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-8">
      <Card className="w-full max-w-sm">
        <CardContent className="p-6">
          <div className="flex flex-col items-center mb-6">
            <div className="w-14 h-14 rounded-2xl bg-primary-light flex items-center justify-center mb-3">
              <Stethoscope className="w-7 h-7 text-primary" />
            </div>
            <h1 className="text-xl font-bold">Shifokor ro'yxatdan o'tish</h1>
            <p className="text-sm text-text-secondary mt-1">Professional hisobingizni yarating</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {error && <div className="bg-danger/10 text-danger text-sm p-3 rounded-xl">{error}</div>}

            <h3 className="font-semibold text-sm">Shaxsiy ma'lumotlar</h3>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Ism" error={errors.first_name?.message} {...register("first_name")} />
              <Input label="Familiya" error={errors.last_name?.message} {...register("last_name")} />
            </div>
            <Input label="Telefon raqam" placeholder="+998901234567" error={errors.phone?.message} {...register("phone")} />
            <div className="grid grid-cols-2 gap-3">
              <Input label="Parol" type="password" error={errors.password?.message} {...register("password")} />
              <Input label="Parolni tasdiqlang" type="password" error={errors.password2?.message} {...register("password2")} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="block text-sm font-medium text-text">Jins</label>
                <select className="block w-full rounded-2xl border border-border px-3 py-2.5 text-sm outline-none focus:border-primary bg-surface" {...register("gender")}>
                  <option value="">Tanlang</option>
                  <option value="male">Erkak</option>
                  <option value="female">Ayol</option>
                </select>
                {errors.gender && <p className="text-xs text-danger">{errors.gender.message}</p>}
              </div>
              <Input label="Tajriba (yil)" type="number" error={errors.experience_years?.message} {...register("experience_years")} />
            </div>
            <Input label="Mutaxassisliklar (vergul bilan)" placeholder="Ortodontist, Implantolog" {...register("specializations")} />

            <div className="space-y-1">
              <label className="block text-sm font-medium text-text">Bemor turi</label>
              <select className="block w-full rounded-2xl border border-border px-3 py-2.5 text-sm outline-none focus:border-primary bg-surface" {...register("patient_type")}>
                <option value="both">Ikkalasi ham</option>
                <option value="adults">Kattalar uchun</option>
                <option value="children">Bolalar uchun</option>
              </select>
            </div>

            <h3 className="font-semibold text-sm pt-2">Klinika ma'lumotlari</h3>
            <Input label="Klinika nomi" error={errors.clinic_name?.message} {...register("clinic_name")} />

            <LocationPicker onLocationSelect={setLocation} />

            {location && (
              <p className="text-xs text-text-secondary bg-bg p-2 rounded-xl leading-relaxed">
                {location.formatted_address}
              </p>
            )}

            <Button type="submit" className="w-full" loading={registerMutation.isPending}>
              Shifokor sifatida ro'yxatdan o'tish
            </Button>
          </form>

          <div className="mt-6 text-center space-y-2">
            <p className="text-sm text-text-secondary">
              Hisobingiz bormi?{" "}
              <Link href="/auth/login" className="text-primary font-medium hover:underline">
                Kirish
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
