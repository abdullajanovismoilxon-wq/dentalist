"use client";
import { useState, useEffect } from "react";
import { useSchedules, useCreateSchedule, useDeleteSchedule, useToggleSlot } from "@/hooks/useSchedule";
import { useAuthStore } from "@/stores/authStore";
import { Button } from "@/components/ui/Button";
import { Card, CardContent } from "@/components/ui/Card";
import { Stethoscope, Plus, Trash2, Clock } from "lucide-react";
import Link from "next/link";

const WEEKDAYS = ["Dushanba", "Seshanba", "Chorshanba", "Payshanba", "Juma", "Shanba", "Yakshanba"];

export default function SchedulePage() {
  const user = useAuthStore((s) => s.user);
  const { data: schedules, isLoading } = useSchedules();
  const createSchedule = useCreateSchedule();
  const deleteSchedule = useDeleteSchedule();

  const [showForm, setShowForm] = useState(false);
  const [weekday, setWeekday] = useState(0);
  const [startTime, setStartTime] = useState("08:00");
  const [endTime, setEndTime] = useState("21:00");
  const [is247, setIs247] = useState(false);

  if (user?.role !== "doctor") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Stethoscope className="w-16 h-16 text-text-secondary/30 mb-4" />
        <h2 className="text-lg font-semibold">Shifokor paneli</h2>
        <p className="text-text-secondary text-sm mt-1">Bu sahifa faqat shifokorlar uchun</p>
      </div>
    );
  }

  const handleAddSchedule = async () => {
    await createSchedule.mutateAsync({
      weekday,
      start_time: is247 ? "00:00" : startTime,
      end_time: is247 ? "23:59" : endTime,
      is_24_7: is247,
    });
    setShowForm(false);
    setStartTime("08:00");
    setEndTime("21:00");
    setIs247(false);
  };

  return (
    <div className="px-4 pt-4 pb-20 space-y-5">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-lg font-bold">Ish vaqti</h1>
          <p className="text-xs text-text-secondary">Kunlar bo'yicha ish vaqtini belgilang</p>
        </div>
        <Button size="sm" onClick={() => setShowForm(!showForm)}>
          <Plus className="w-4 h-4 mr-1" /> Qo'shish
        </Button>
      </div>

      {/* Add Schedule Form */}
      {showForm && (
        <Card>
          <CardContent className="p-4 space-y-3">
            <div>
              <label className="block text-xs font-medium text-text mb-1">Kun</label>
              <select
                value={weekday}
                onChange={(e) => setWeekday(parseInt(e.target.value))}
                className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
              >
                {WEEKDAYS.map((name, i) => (
                  <option key={i} value={i}>{name}</option>
                ))}
              </select>
            </div>

            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="is247"
                checked={is247}
                onChange={(e) => setIs247(e.target.checked)}
                className="rounded accent-primary"
              />
              <label htmlFor="is247" className="text-sm">24/7 rejim</label>
            </div>

            {!is247 && (
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-text mb-1">Boshlanish</label>
                  <input
                    type="time"
                    value={startTime}
                    onChange={(e) => setStartTime(e.target.value)}
                    className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-text mb-1">Tugash</label>
                  <input
                    type="time"
                    value={endTime}
                    onChange={(e) => setEndTime(e.target.value)}
                    className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
                  />
                </div>
              </div>
            )}

            <Button className="w-full" onClick={handleAddSchedule} loading={createSchedule.isPending}>
              Saqlash
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Schedule List */}
      {isLoading ? (
        <div className="space-y-2">
          {[0, 1, 2, 3, 4].map((i) => (
            <div key={i} className="h-16 bg-gray-100 rounded-2xl animate-pulse" />
          ))}
        </div>
      ) : schedules && schedules.length > 0 ? (
        <div className="space-y-2">
          {schedules.map((sched) => (
            <Card key={sched.id}>
              <CardContent className="p-3 flex items-center justify-between">
                <div>
                  <p className="font-medium text-sm">{WEEKDAYS[sched.weekday]}</p>
                  <p className="text-xs text-text-secondary">
                    {sched.is_24_7 ? (
                      <span className="text-primary font-medium">24/7</span>
                    ) : (
                      <><Clock className="w-3 h-3 inline mr-1" />{sched.start_time.slice(0, 5)} — {sched.end_time.slice(0, 5)}</>
                    )}
                  </p>
                </div>
                <button onClick={() => deleteSchedule.mutate(sched.id)} className="p-2 text-text-secondary hover:text-danger transition-colors">
                  <Trash2 className="w-4 h-4" />
                </button>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="text-center py-12 text-text-secondary">
          <Clock className="w-10 h-10 mx-auto mb-2 opacity-30" />
          <p className="text-sm">Ish vaqti belgilanmagan</p>
          <p className="text-xs mt-1">Yuqoridagi "Qo'shish" tugmasini bosing</p>
        </div>
      )}
    </div>
  );
}
