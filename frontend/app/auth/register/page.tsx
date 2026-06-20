"use client";
import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useRegister } from "@/hooks/useAuth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Card, CardContent } from "@/components/ui/Card";
import { Smile, UserPlus } from "lucide-react";

const schema = z
  .object({
    first_name: z.string().min(1, "Ism kiritilishi shart"),
    last_name: z.string().min(1, "Familiya kiritilishi shart"),
    phone: z.string().min(7, "Telefon raqam noto'g'ri"),
    password: z.string().min(8, "Kamida 8 ta belgi"),
    password2: z.string().min(8, "Parolni tasdiqlang"),
    blood_group: z.string().optional(),
    gender: z.string().optional(),
  })
  .refine((d) => d.password === d.password2, {
    message: "Parollar mos kelmadi",
    path: ["password2"],
  });

type FormData = z.infer<typeof schema>;

export default function RegisterPage() {
  const registerMutation = useRegister();
  const [error, setError] = useState("");
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    setError("");
    try {
      await registerMutation.mutateAsync(data as unknown as Record<string, unknown>);
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
              <UserPlus className="w-7 h-7 text-primary" />
            </div>
            <h1 className="text-xl font-bold">Ro'yxatdan o'tish</h1>
            <p className="text-sm text-text-secondary mt-1">Bemor sifatida ro'yxatdan o'ting</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {error && (
              <div className="bg-danger/10 text-danger text-sm p-3 rounded-xl">{error}</div>
            )}
            <div className="grid grid-cols-2 gap-3">
              <Input label="Ism" error={errors.first_name?.message} {...register("first_name")} />
              <Input label="Familiya" error={errors.last_name?.message} {...register("last_name")} />
            </div>
            <Input label="Telefon raqam" placeholder="+998901234567" error={errors.phone?.message} {...register("phone")} />
            <Input label="Parol" type="password" error={errors.password?.message} {...register("password")} />
            <Input label="Parolni tasdiqlang" type="password" error={errors.password2?.message} {...register("password2")} />

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <label className="block text-sm font-medium text-text">Qon guruhi</label>
                <select className="block w-full rounded-2xl border border-border px-3 py-2.5 text-sm outline-none focus:border-primary bg-surface" {...register("blood_group")}>
                  <option value="">Tanlang</option>
                  {["I+", "I-", "II+", "II-", "III+", "III-", "IV+", "IV-"].map((bg) => (
                    <option key={bg} value={bg}>{bg}</option>
                  ))}
                </select>
              </div>
              <div className="space-y-1">
                <label className="block text-sm font-medium text-text">Jins</label>
                <select className="block w-full rounded-2xl border border-border px-3 py-2.5 text-sm outline-none focus:border-primary bg-surface" {...register("gender")}>
                  <option value="">Tanlang</option>
                  <option value="male">Erkak</option>
                  <option value="female">Ayol</option>
                </select>
              </div>
            </div>

            <Button type="submit" className="w-full" loading={registerMutation.isPending}>
              Ro'yxatdan o'tish
            </Button>
          </form>

          <div className="mt-6 text-center space-y-2">
            <p className="text-sm text-text-secondary">
              Shifokormisiz?{" "}
              <Link href="/auth/register-doctor" className="text-primary font-medium hover:underline">
                Shifokor sifatida ro'yxatdan o'tish
              </Link>
            </p>
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
