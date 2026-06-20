"use client";
import { useState } from "react";
import { useAuthStore } from "@/stores/authStore";
import { useToggleSlot } from "@/hooks/useSchedule";
import { useQuery } from "@tanstack/react-query";
import api from "@/services/api";
import { Card, CardContent } from "@/components/ui/Card";
import { Stethoscope, CalendarDays } from "lucide-react";
import type { TimeSlot } from "@/types";

export default function SlotsPage() {
  const user = useAuthStore((s) => s.user);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split("T")[0]);
  const toggleSlot = useToggleSlot();

  const { data, isLoading } = useQuery({
    queryKey: ["doctor-slots", selectedDate],
    queryFn: async () => {
      const res = await api.get("/doctors/slots/", { params: { date: selectedDate } });
      return res.data.slots as TimeSlot[];
    },
    enabled: user?.role === "doctor",
  });

  const slots = data;

  if (user?.role !== "doctor") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Stethoscope className="w-16 h-16 text-text-secondary/30 mb-4" />
        <h2 className="text-lg font-semibold">Shifokor paneli</h2>
        <p className="text-text-secondary text-sm mt-1">Bu sahifa faqat shifokorlar uchun</p>
      </div>
    );
  }

  const handleToggle = async (slot: TimeSlot) => {
    if (slot.status === "booked") return;
    await toggleSlot.mutateAsync(slot.id);
  };

  const getSlotStyle = (slot: TimeSlot) => {
    switch (slot.status) {
      case "available":
        return "bg-green-100 text-green-700 border-green-300 hover:bg-green-200";
      case "blocked":
        return "bg-yellow-100 text-yellow-700 border-yellow-300 hover:bg-yellow-200";
      case "booked":
        return "bg-red-100 text-red-700 border-red-300 cursor-not-allowed opacity-70";
      default:
        return "border-border text-text";
    }
  };

  const slotLabel = (slot: TimeSlot) => {
    switch (slot.status) {
      case "available": return "AVAILABLE";
      case "blocked": return "BLOCKED";
      case "booked": return "BOOKED";
      default: return slot.status;
    }
  };

  return (
    <div className="px-4 pt-4 pb-20 space-y-5">
      <div>
        <h1 className="text-lg font-bold">Slotlar</h1>
        <p className="text-xs text-text-secondary">Vaqtlarni bosing va bloklang</p>
      </div>

      {/* Date Picker */}
      <div className="flex items-center gap-3">
        <CalendarDays className="w-5 h-5 text-primary flex-shrink-0" />
        <input
          type="date"
          value={selectedDate}
          onChange={(e) => setSelectedDate(e.target.value)}
          className="flex-1 rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
        />
      </div>

      {/* Legend */}
      <div className="flex gap-4 text-xs">
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-green-100 border border-green-300" /> Bo'sh</span>
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-yellow-100 border border-yellow-300" /> Bloklangan</span>
        <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-red-100 border border-red-300" /> Band</span>
      </div>

      {/* Slots Grid */}
      {isLoading ? (
        <div className="grid grid-cols-4 gap-2">
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i} className="h-14 bg-gray-100 rounded-2xl animate-pulse" />
          ))}
        </div>
      ) : slots && slots.length > 0 ? (
        <div className="grid grid-cols-4 gap-2">
          {slots.map((slot) => (
            <button
              key={slot.id}
              onClick={() => handleToggle(slot)}
              disabled={slot.status === "booked"}
              className={`py-3 rounded-2xl text-sm font-medium border transition-colors ${getSlotStyle(slot)}`}
            >
              <div>{slot.start_time.slice(0, 5)}</div>
              <div className="text-[10px] opacity-75">{slotLabel(slot)}</div>
            </button>
          ))}
        </div>
      ) : (
        <div className="text-center py-12 text-text-secondary">
          <p className="text-sm">Bu sana uchun slotlar mavjud emas</p>
          <p className="text-xs mt-1">Avval ish vaqtini belgilang</p>
        </div>
      )}

      {/* Instructions */}
      <Card>
        <CardContent className="p-4 space-y-1">
          <p className="text-sm font-medium">Qanday ishlaydi?</p>
          <ul className="text-xs text-text-secondary space-y-1">
            <li>• Yashil tugma = Slot bo'sh (AVAILABLE)</li>
            <li>• Sariq tugma = Siz bloklagan (BLOCKED)</li>
            <li>• Qizil tugma = Bemor band qilgan (BOOKED)</li>
            <li>• Yashil tugmani bossangiz → SARIQ (bloklanadi)</li>
            <li>• Sariq tugmani bossangiz → YASHIL (ochiladi)</li>
            <li>• Qizil tugmani o'zgartirib bo'lmaydi</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}
