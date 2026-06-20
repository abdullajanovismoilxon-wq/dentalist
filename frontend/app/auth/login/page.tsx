"use client";
import { useState } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { useLogin } from "@/hooks/useAuth";
import { Input } from "@/components/ui/Input";
import { Button } from "@/components/ui/Button";
import { Card, CardContent } from "@/components/ui/Card";
import { Smile } from "lucide-react";

const schema = z.object({
  phone: z.string().min(1, "Telefon raqam kiritilishi shart"),
  password: z.string().min(1, "Parol kiritilishi shart"),
});

type FormData = z.infer<typeof schema>;

export default function LoginPage() {
  const login = useLogin();
  const [error, setError] = useState("");
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<FormData>({ resolver: zodResolver(schema) });

  const onSubmit = async (data: FormData) => {
    setError("");
    try {
      await login.mutateAsync(data);
    } catch (err: unknown) {
      const resp = (err as { response?: { data?: { errors?: Array<Record<string, string>> } } })?.response?.data;
      const msgs = resp?.errors;
      if (msgs?.length) {
        setError(Object.values(msgs[0])[0]);
      } else {
        setError("Telefon raqam yoki parol noto'g'ri");
      }
    }
  };

  return (
    <div className="min-h-[80vh] flex items-center justify-center px-4">
      <Card className="w-full max-w-sm">
        <CardContent className="p-6">
          <div className="flex flex-col items-center mb-6">
            <div className="w-14 h-14 rounded-2xl bg-primary-light flex items-center justify-center mb-3">
              <Smile className="w-7 h-7 text-primary" />
            </div>
            <h1 className="text-xl font-bold">Xush kelibsiz</h1>
            <p className="text-sm text-text-secondary mt-1">Hisobingizga kiring</p>
          </div>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {error && (
              <div className="bg-danger/10 text-danger text-sm p-3 rounded-xl">{error}</div>
            )}
            <Input
              label="Telefon raqam"
              placeholder="+998901234567"
              error={errors.phone?.message}
              {...register("phone")}
            />
            <Input
              label="Parol"
              type="password"
              placeholder="••••••••"
              error={errors.password?.message}
              {...register("password")}
            />
            <Button type="submit" className="w-full" loading={login.isPending}>
              Kirish
            </Button>
          </form>

          <div className="mt-6 text-center space-y-2">
            <p className="text-sm text-text-secondary">
              Hisobingiz yo'qmi?{" "}
              <Link href="/auth/register" className="text-primary font-medium hover:underline">
                Ro'yxatdan o'tish
              </Link>
            </p>
            <p className="text-sm text-text-secondary">
              Shifokormisiz?{" "}
              <Link href="/auth/register-doctor" className="text-primary font-medium hover:underline">
                Shifokor sifatida ro'yxatdan o'tish
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
