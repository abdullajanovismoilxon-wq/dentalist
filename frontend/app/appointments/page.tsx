"use client";
import { useMyAppointments, useCancelAppointment, useConfirmAppointment } from "@/hooks/useAppointments";
import { useAuthStore } from "@/stores/authStore";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Calendar, Clock, Stethoscope, User } from "lucide-react";
import Link from "next/link";
import { formatDate, formatTime } from "@/utils";

const statusMap: Record<string, { label: string; variant: "warning" | "success" | "info" | "danger" }> = {
  pending: { label: "Kutilmoqda", variant: "warning" },
  confirmed: { label: "Tasdiqlangan", variant: "success" },
  completed: { label: "Bajarilgan", variant: "info" },
  cancelled: { label: "Bekor qilingan", variant: "danger" },
};

export default function AppointmentsPage() {
  const { data: appointments, isLoading } = useMyAppointments();
  const cancelAppointment = useCancelAppointment();
  const confirmAppointment = useConfirmAppointment();
  const user = useAuthStore((s) => s.user);

  if (!user) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Calendar className="w-16 h-16 text-text-secondary/30 mb-4" />
        <p className="text-text-secondary mb-4">Qabullarni ko'rish uchun kiring</p>
        <Link href="/auth/login"><Button>Kirish</Button></Link>
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto px-4 pt-4 pb-4 space-y-4">
      <h1 className="text-lg font-bold">Mening qabullarim</h1>

      {isLoading ? (
        <div className="space-y-3">
          {[1, 2].map((i) => (
            <div key={i} className="bg-surface rounded-2xl border border-border p-4 animate-pulse space-y-2">
              <div className="h-4 bg-gray-200 rounded w-1/3" />
              <div className="h-3 bg-gray-200 rounded w-1/2" />
            </div>
          ))}
        </div>
      ) : !appointments?.length ? (
        <div className="flex flex-col items-center justify-center py-16 text-text-secondary">
          <Calendar className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p className="text-sm">Qabullar mavjud emas</p>
          <Link href="/" className="text-primary text-sm mt-2 font-medium">Shifokor qidirish</Link>
        </div>
      ) : (
        <div className="space-y-3">
          {appointments.map((apt) => {
            const st = statusMap[apt.status] || statusMap.pending;
            return (
              <Card key={apt.id}>
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className="w-12 h-12 rounded-2xl bg-primary-light flex items-center justify-center flex-shrink-0">
                      <Stethoscope className="w-6 h-6 text-primary" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <h3 className="font-semibold text-sm">{apt.doctor_detail?.full_name || `Shifokor #${apt.doctor}`}</h3>
                          <p className="text-xs text-text-secondary mt-0.5">
                            {formatDate(apt.appointment_date)} • {formatTime(apt.appointment_time)}
                          </p>
                        </div>
                        <Badge variant={st.variant} className="flex-shrink-0">{st.label}</Badge>
                      </div>
                      {apt.note && <p className="text-xs text-text-secondary mt-2">{apt.note}</p>}
                      {apt.status === "pending" && (
                        <div className="flex gap-2 mt-3">
                          {user.role === "doctor" && (
                            <Button size="sm" onClick={() => confirmAppointment.mutate(apt.id)}>
                              Tasdiqlash
                            </Button>
                          )}
                          <Button size="sm" variant="outline" onClick={() => cancelAppointment.mutate(apt.id)}>
                            Bekor qilish
                          </Button>
                        </div>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
