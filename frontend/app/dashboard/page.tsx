"use client";
import { useState, useRef } from "react";
import { useAuthStore } from "@/stores/authStore";
import { useMyAppointments, useConfirmAppointment, useCancelAppointment } from "@/hooks/useAppointments";
import { useNotifications, useUnreadCount } from "@/hooks/useNotifications";
import { useSchedules, useCreateSchedule, useDeleteSchedule } from "@/hooks/useSchedule";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import {
  Calendar, Clock, Users, Star, Settings, Stethoscope, Building2, Image as ImageIcon,
  ChevronRight, Timer, Ban, CheckCircle, Bell, X, Plus, Trash2, MessageCircle, Camera,
  Phone, MapPin, Award, CalendarCheck, UserCheck, AlertCircle, Activity
} from "lucide-react";
import Link from "next/link";
import { formatDate, formatTime, formatRating, formatPrice } from "@/utils";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import api from "@/services/api";
import type { Appointment, ClinicImage } from "@/types";
import { useRouter } from "next/navigation";

const WEEKDAYS = ["Dushanba", "Seshanba", "Chorshanba", "Payshanba", "Juma", "Shanba", "Yakshanba"];

export default function DashboardPage() {
  const user = useAuthStore((s) => s.user);
  const router = useRouter();
  const queryClient = useQueryClient();
  const { data: appointments } = useMyAppointments();
  const confirmAppointment = useConfirmAppointment();
  const cancelAppointment = useCancelAppointment();
  const { data: notifications } = useNotifications();
  const { data: unreadData } = useUnreadCount();
  const { data: schedules, isLoading: schedLoading } = useSchedules();
  const createSchedule = useCreateSchedule();
  const deleteSchedule = useDeleteSchedule();

  const [activeTab, setActiveTab] = useState<"overview" | "appointments" | "schedule" | "gallery" | "services" | "notifications">("overview");

  const { data: stats } = useQuery({
    queryKey: ["doctor-dashboard-stats"],
    queryFn: async () => {
      const res = await api.get("/doctors/dashboard/");
      return res.data;
    },
    enabled: user?.role === "doctor",
  });

  const { data: profile } = useQuery({
    queryKey: ["doctor-profile"],
    queryFn: async () => {
      const res = await api.get("/doctors/profile/");
      return res.data;
    },
    enabled: user?.role === "doctor",
  });

  const { data: gallery, isLoading: galleryLoading } = useQuery({
    queryKey: ["doctor-clinic-gallery"],
    queryFn: async () => {
      if (!profile?.clinic?.id) return [];
      const res = await api.get(`/clinics/${profile.clinic.id}/`);
      return res.data.gallery as ClinicImage[];
    },
    enabled: user?.role === "doctor" && !!profile?.clinic?.id,
  });

  const [showScheduleForm, setShowScheduleForm] = useState(false);
  const [weekday, setWeekday] = useState(0);
  const [startTime, setStartTime] = useState("08:00");
  const [endTime, setEndTime] = useState("21:00");
  const [is247, setIs247] = useState(false);
  const [uploading, setUploading] = useState(false);
  const avatarInputRef = useRef<HTMLInputElement>(null);
  const galleryInputRef = useRef<HTMLInputElement>(null);

  const handleAddSchedule = async () => {
    await createSchedule.mutateAsync({
      weekday,
      start_time: is247 ? "00:00" : startTime,
      end_time: is247 ? "23:59" : endTime,
      is_24_7: is247,
    });
    setShowScheduleForm(false);
    setStartTime("08:00");
    setEndTime("21:00");
    setIs247(false);
  };

  const deleteGalleryImage = useMutation({
    mutationFn: async (imageId: number) => {
      await api.delete(`/clinics/gallery/${imageId}/delete/`);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["doctor-clinic-gallery"] });
      queryClient.invalidateQueries({ queryKey: ["clinics"] });
    },
  });

  const handleUploadImage = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    try {
      console.log("[Dashboard] Uploading gallery image:", file.name, file.size);
      const formData = new FormData();
      formData.append("image", file);
      const res = await api.post("/doctors/clinic/upload-image/", formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      console.log("[Dashboard] Gallery upload success:", res.status);
      queryClient.invalidateQueries({ queryKey: ["doctor-clinic-gallery"] });
      queryClient.invalidateQueries({ queryKey: ["clinics"] });
    } catch (err: any) {
      console.error("[Dashboard] Gallery upload failed:", err?.response?.data || err?.message || err);
      alert(err?.response?.data?.error || err?.message || "Rasm yuklashda xatolik");
    }
    setUploading(false);
    e.target.value = "";
  };

  const todayAppointments = appointments?.filter(a => a.appointment_date === new Date().toISOString().split("T")[0]) || [];
  const futureAppointments = appointments?.filter(a =>
    a.appointment_date > new Date().toISOString().split("T")[0] && a.status !== "cancelled"
  ) || [];
  const cancelledAppointments = appointments?.filter(a => a.status === "cancelled") || [];
  const pendingConfirmations = appointments?.filter(a => a.status === "pending") || [];

  if (user?.role !== "doctor") {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Stethoscope className="w-16 h-16 text-text-secondary/30 mb-4" />
        <h2 className="text-lg font-semibold">Shifokor paneli</h2>
        <p className="text-text-secondary text-sm mt-1">Bu sahifa faqat shifokorlar uchun</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 pt-4 pb-24 space-y-4">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-primary to-primary-light flex items-center justify-center">
            <Activity className="w-5 h-5 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold">Boshqaruv paneli</h1>
            <p className="text-xs text-text-secondary">Xush kelibsiz, {user.first_name}</p>
          </div>
        </div>
        <Link href="/profile">
          <Button variant="outline" size="sm"><Settings className="w-4 h-4 mr-1" /> Sozlash</Button>
        </Link>
      </div>

      {/* Stats Row */}
      <div className="grid grid-cols-4 gap-2">
        <Card>
          <CardContent className="p-3 text-center">
            <p className="text-lg font-bold text-primary">{stats?.total_appointments || 0}</p>
            <p className="text-[10px] text-text-secondary">Jami</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-3 text-center">
            <p className="text-lg font-bold text-yellow-600">{stats?.pending || 0}</p>
            <p className="text-[10px] text-text-secondary">Kutilmoqda</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-3 text-center">
            <p className="text-lg font-bold text-green-600">{stats?.confirmed || 0}</p>
            <p className="text-[10px] text-text-secondary">Tasdiqlangan</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-3 text-center">
            <p className="text-lg font-bold text-blue-600">{stats?.completed || 0}</p>
            <p className="text-[10px] text-text-secondary">Bajarilgan</p>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 overflow-x-auto scrollbar-hide -mx-4 px-4 pb-1">
        {[
          { key: "overview", label: "Asosiy", icon: Activity },
          { key: "appointments", label: "Qabullar", icon: Calendar },
          { key: "schedule", label: "Ish vaqti", icon: Clock },
          { key: "gallery", label: "Galereya", icon: ImageIcon },
          { key: "services", label: "Xizmatlar", icon: Star },
          { key: "notifications", label: "Bildirishnomalar", icon: Bell },
        ].map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key as typeof activeTab)}
            className={`flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-medium whitespace-nowrap transition-colors ${
              activeTab === tab.key ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"
            }`}
          >
            <tab.icon className="w-3.5 h-3.5" />
            {tab.label}
            {tab.key === "notifications" && (unreadData || 0) > 0 && (
              <span className="w-4 h-4 rounded-full bg-danger text-white text-[9px] flex items-center justify-center font-bold">
                {unreadData || 0}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === "overview" && (
        <div className="space-y-4">
          {/* Quick stats */}
          <div className="grid grid-cols-2 gap-3">
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-primary-light text-primary">
                    <Calendar className="w-5 h-5" />
                  </div>
                  <div>
                    <p className="text-xl font-bold">{stats?.today_appointments || 0}</p>
                    <p className="text-[10px] text-text-secondary">Bugungi qabullar</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-blue-50 text-blue-600">
                    <CalendarCheck className="w-5 h-5" />
                  </div>
                  <div>
                    <p className="text-xl font-bold">{stats?.tomorrow_appointments || 0}</p>
                    <p className="text-[10px] text-text-secondary">Ertangi qabullar</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-green-50 text-green-600">
                    <UserCheck className="w-5 h-5" />
                  </div>
                  <div>
                    <p className="text-xl font-bold">{formatRating(stats?.avg_rating || 0)}</p>
                    <p className="text-[10px] text-text-secondary">Reyting</p>
                  </div>
                </div>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="p-4">
                <div className="flex items-center gap-3">
                  <div className="p-2 rounded-xl bg-purple-50 text-purple-600">
                    <Star className="w-5 h-5" />
                  </div>
                  <div>
                    <p className="text-xl font-bold">{stats?.review_count || 0}</p>
                    <p className="text-[10px] text-text-secondary">Sharhlar</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Slot today */}
          <Card>
            <CardContent className="p-4">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-sm font-semibold">Bugungi slotlar</h3>
                <Link href="/dashboard/slots" className="text-xs text-primary font-medium">Boshqarish</Link>
              </div>
              <div className="grid grid-cols-4 gap-2">
                <div className="text-center">
                  <p className="text-lg font-bold text-text">{stats?.total_slots_today || 0}</p>
                  <p className="text-[10px] text-text-secondary">Jami</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-bold text-green-600">{stats?.available_slots_today || 0}</p>
                  <p className="text-[10px] text-text-secondary">Bo'sh</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-bold text-red-600">{stats?.booked_slots_today || 0}</p>
                  <p className="text-[10px] text-text-secondary">Band</p>
                </div>
                <div className="text-center">
                  <p className="text-lg font-bold text-yellow-600">{stats?.blocked_slots_today || 0}</p>
                  <p className="text-[10px] text-text-secondary">Bloklangan</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Today's Appointments */}
          <div>
            <h2 className="text-sm font-semibold mb-2 flex items-center gap-1">
              <Calendar className="w-4 h-4 text-primary" /> Bugun
            </h2>
            {todayAppointments.length > 0 ? (
              <div className="space-y-2">
                {todayAppointments.slice(0, 5).map((apt) => (
                  <AppointmentCard
                    key={apt.id}
                    apt={apt}
                    isDoctor
                    onConfirm={() => confirmAppointment.mutate(apt.id)}
                    onCancel={() => cancelAppointment.mutate(apt.id)}
                  />
                ))}
              </div>
            ) : (
              <p className="text-xs text-text-secondary text-center py-4">Bugungi qabullar yo'q</p>
            )}
          </div>

          {/* Quick Links */}
          <div className="space-y-1">
            <h3 className="text-sm font-semibold mb-2">Tez o'tish</h3>
            <QuickLink href="/dashboard/schedule" icon={Clock} label="Ish vaqti" />
            <QuickLink href="/dashboard/slots" icon={Timer} label="Slotlarni boshqarish" />
            <QuickLink href="/appointments" icon={Calendar} label="Barcha qabullar" />
            <QuickLink href="/profile" icon={Settings} label="Profil tahrirlash" />
          </div>
        </div>
      )}

      {activeTab === "appointments" && (
        <div className="space-y-4">
          {/* Pending Confirmations */}
          {pendingConfirmations.length > 0 && (
            <div>
              <h2 className="text-sm font-semibold mb-2 flex items-center gap-1 text-yellow-600">
                <AlertCircle className="w-4 h-4" /> Tasdiqlanishi kerak ({pendingConfirmations.length})
              </h2>
              <div className="space-y-2">
                {pendingConfirmations.map((apt) => (
                  <AppointmentCard
                    key={apt.id}
                    apt={apt}
                    isDoctor
                    onConfirm={() => confirmAppointment.mutate(apt.id)}
                    onCancel={() => cancelAppointment.mutate(apt.id)}
                  />
                ))}
              </div>
            </div>
          )}

          {/* Today */}
          <div>
            <h2 className="text-sm font-semibold mb-2">Bugungi qabullar</h2>
            <div className="space-y-2">
              {todayAppointments.length > 0 ? todayAppointments.map((apt) => (
                <AppointmentCard
                  key={apt.id}
                  apt={apt}
                  isDoctor
                  onConfirm={() => confirmAppointment.mutate(apt.id)}
                  onCancel={() => cancelAppointment.mutate(apt.id)}
                />
              )) : <p className="text-xs text-text-secondary text-center py-4">Yo'q</p>}
            </div>
          </div>

          {/* Future */}
          <div>
            <h2 className="text-sm font-semibold mb-2">Kelajakdagi qabullar</h2>
            <div className="space-y-2">
              {futureAppointments.length > 0 ? futureAppointments.map((apt) => (
                <AppointmentCard
                  key={apt.id}
                  apt={apt}
                  isDoctor
                  onConfirm={() => confirmAppointment.mutate(apt.id)}
                  onCancel={() => cancelAppointment.mutate(apt.id)}
                />
              )) : <p className="text-xs text-text-secondary text-center py-4">Yo'q</p>}
            </div>
          </div>

          {/* Cancelled */}
          <div>
            <h2 className="text-sm font-semibold mb-2">Bekor qilingan qabullar</h2>
            <div className="space-y-2">
              {cancelledAppointments.length > 0 ? cancelledAppointments.map((apt) => (
                <AppointmentCard key={apt.id} apt={apt} isDoctor />
              )) : <p className="text-xs text-text-secondary text-center py-4">Yo'q</p>}
            </div>
          </div>

          {/* All */}
          <Link href="/appointments" className="block text-center text-xs text-primary font-medium py-2">
            Barcha qabullarni ko'rish
          </Link>
        </div>
      )}

      {activeTab === "schedule" && (
        <div className="space-y-4">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold">Ish vaqtlari</h2>
            <Button size="sm" onClick={() => setShowScheduleForm(!showScheduleForm)}>
              <Plus className="w-4 h-4 mr-1" /> Qo'shish
            </Button>
          </div>

          {showScheduleForm && (
            <Card>
              <CardContent className="p-4 space-y-3">
                <div>
                  <label className="block text-xs font-medium text-text mb-1">Kun</label>
                  <select value={weekday} onChange={(e) => setWeekday(parseInt(e.target.value))}
                    className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary">
                    {WEEKDAYS.map((name, i) => <option key={i} value={i}>{name}</option>)}
                  </select>
                </div>
                <div className="flex items-center gap-2">
                  <input type="checkbox" id="is247" checked={is247} onChange={(e) => setIs247(e.target.checked)}
                    className="rounded accent-primary" />
                  <label htmlFor="is247" className="text-sm">24/7 rejim</label>
                </div>
                {!is247 && (
                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-xs font-medium text-text mb-1">Boshlanish</label>
                      <input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)}
                        className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary" />
                    </div>
                    <div>
                      <label className="block text-xs font-medium text-text mb-1">Tugash</label>
                      <input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)}
                        className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary" />
                    </div>
                  </div>
                )}
                <Button className="w-full" onClick={handleAddSchedule} loading={createSchedule.isPending}>Saqlash</Button>
              </CardContent>
            </Card>
          )}

          {schedLoading ? (
            <div className="space-y-2">
              {[1,2,3].map(i => <div key={i} className="h-14 bg-gray-100 rounded-xl animate-pulse" />)}
            </div>
          ) : schedules && schedules.length > 0 ? (
            <div className="space-y-2">
              {schedules.map((s) => (
                <Card key={s.id}>
                  <CardContent className="p-3 flex items-center justify-between">
                    <div>
                      <p className="font-medium text-sm">{WEEKDAYS[s.weekday]}</p>
                      <p className="text-xs text-text-secondary">
                        {s.is_24_7 ? <span className="text-primary font-medium">24/7</span> : <>{s.start_time.slice(0,5)} — {s.end_time.slice(0,5)}</>}
                      </p>
                    </div>
                    <button onClick={() => deleteSchedule.mutate(s.id)} className="p-2 text-text-secondary hover:text-danger">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-text-secondary">
              <Clock className="w-8 h-8 mx-auto mb-2 opacity-30" />
              <p className="text-sm">Ish vaqti belgilanmagan</p>
            </div>
          )}
        </div>
      )}

      {activeTab === "gallery" && (
        <div className="space-y-6">
          {/* Clinic Profile Image */}
          {profile?.clinic && (
            <div className="bg-surface rounded-2xl border border-border p-4">
              <h2 className="text-sm font-semibold mb-3">Klinika profil rasmi</h2>
              <div className="flex items-center gap-4">
                <div className="relative group w-24 h-24 rounded-2xl overflow-hidden flex-shrink-0 bg-gray-100">
                  {profile.clinic.image ? (
                    <img src={profile.clinic.image} alt="" className="w-full h-full object-cover" />
                  ) : (
                    <Building2 className="w-8 h-8 text-text-secondary/30 absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2" />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium">{profile.clinic.name}</p>
                  <p className="text-xs text-text-secondary mt-1">{profile.clinic.address}</p>
                  <div className="flex gap-2 mt-2">
                    <input type="file" ref={avatarInputRef} accept="image/*" className="hidden" onChange={async (e) => {
                      const file = e.target.files?.[0];
                      if (!file) return;
                      if (!profile?.clinic?.id) {
                        console.error("[Dashboard] No clinic ID for avatar upload");
                        alert("Klinika ma'lumotlari topilmadi");
                        e.target.value = "";
                        return;
                      }
                      console.log("[Dashboard] Uploading clinic avatar:", file.name, file.size, "to clinic", profile.clinic.id);
                      const fd = new FormData();
                      fd.append("image", file);
                      try {
                        const res = await api.post(`/clinics/${profile.clinic.id}/avatar/`, fd, {
                          headers: { "Content-Type": "multipart/form-data" },
                        });
                        console.log("[Dashboard] Avatar upload success:", res.status);
                        queryClient.invalidateQueries({ queryKey: ["doctor-profile"] });
                        queryClient.invalidateQueries({ queryKey: ["clinics"] });
                      } catch (err: any) {
                        console.error("[Dashboard] Avatar upload failed:", err?.response?.data || err?.message || err);
                        alert(err?.response?.data?.error || err?.message || "Rasm yuklashda xatolik");
                      }
                      e.target.value = "";
                    }} />
                    <Button size="sm" variant="outline" type="button" onClick={() => avatarInputRef.current?.click()}>
                      <Camera className="w-3.5 h-3.5 mr-1" /> Yuklash
                    </Button>
                    {profile.clinic?.image && (
                      <Button size="sm" variant="ghost" className="text-danger" onClick={async () => {
                        if (!confirm("Rasmni o'chirishni xohlaysizmi?")) return;
                        if (!profile?.clinic?.id) return;
                        try {
                          await api.delete(`/clinics/${profile.clinic.id}/avatar/`);
                          queryClient.invalidateQueries({ queryKey: ["doctor-profile"] });
                          queryClient.invalidateQueries({ queryKey: ["clinics"] });
                        } catch (err: any) {
                          console.error("[Dashboard] Avatar delete failed:", err?.response?.data || err?.message || err);
                        }
                      }}>
                        <Trash2 className="w-3.5 h-3.5" />
                      </Button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Gallery Images */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-sm font-semibold">Klinika galereyasi</h2>
              <input type="file" ref={galleryInputRef} accept="image/*" onChange={handleUploadImage} className="hidden" />
              <Button size="sm" type="button" disabled={uploading} onClick={() => galleryInputRef.current?.click()}>
                <Plus className="w-4 h-4 mr-1" /> {uploading ? "Yuklanmoqda..." : "Rasm qo'shish"}
              </Button>
            </div>

          {galleryLoading ? (
            <div className="grid grid-cols-2 gap-3">
              {[1,2,3,4].map(i => <div key={i} className="h-32 bg-gray-100 rounded-2xl animate-pulse" />)}
            </div>
          ) : gallery && gallery.length > 0 ? (
            <div className="grid grid-cols-2 gap-3">
              {gallery.map((img) => (
                <div key={img.id} className="relative group rounded-2xl overflow-hidden">
                  <img src={img.image} alt="" className="w-full h-32 object-cover" />
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 transition-colors flex items-center justify-center">
                    <button
                      onClick={() => { if (confirm("Rasmni o'chirishni xohlaysizmi?")) deleteGalleryImage.mutate(img.id); }}
                      className="opacity-0 group-hover:opacity-100 p-2 bg-danger text-white rounded-full transition-opacity"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 text-text-secondary">
              <ImageIcon className="w-10 h-10 mx-auto mb-2 opacity-30" />
              <p className="text-sm">Hali rasm yo'q</p>
              <p className="text-xs mt-1">Klinika rasmlarini qo'shing</p>
            </div>
          )}
          </div>

          {profile?.clinic && (
            <Link href={`/clinics/${profile.clinic.id}`}>
              <Button variant="outline" className="w-full">
                <Building2 className="w-4 h-4 mr-1" /> Klinika sahifasini ko'rish
              </Button>
            </Link>
          )}
        </div>
      )}

      {activeTab === "services" && (
        <ServicesManager queryClient={queryClient} />
      )}

      {activeTab === "notifications" && (
        <div className="space-y-3">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-semibold">Bildirishnomalar</h2>
            <Button variant="ghost" size="sm" onClick={async () => {
              await api.patch("/notifications/mark-all-read/");
              queryClient.invalidateQueries({ queryKey: ["notifications"] });
            }}>Hammasini o'qish</Button>
          </div>
          {notifications && notifications.length > 0 ? (
            notifications.map((n) => (
              <Card key={n.id} className={n.is_read ? "" : "border-primary/30 bg-primary/[0.02]"}>
                <CardContent className="p-3 flex items-start gap-3">
                  <div className={`p-2 rounded-xl flex-shrink-0 ${
                    n.type === "appointment_booked" ? "bg-green-50 text-green-600" :
                    n.type === "appointment_confirmed" ? "bg-blue-50 text-blue-600" :
                    n.type === "appointment_cancelled" ? "bg-red-50 text-red-600" :
                    "bg-gray-50 text-gray-600"
                  }`}>
                    {n.type === "new_message" ? <MessageCircle className="w-4 h-4" /> :
                     n.type === "appointment_booked" ? <Calendar className="w-4 h-4" /> :
                     n.type === "appointment_confirmed" ? <CheckCircle className="w-4 h-4" /> :
                     n.type === "appointment_cancelled" ? <X className="w-4 h-4" /> :
                     <Bell className="w-4 h-4" />}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium">{n.title}</p>
                    <p className="text-xs text-text-secondary mt-0.5">{n.message}</p>
                    <p className="text-[10px] text-text-secondary mt-1">{formatDate(n.created_at)}</p>
                  </div>
                  {!n.is_read && (
                    <button onClick={async () => {
                      await api.patch(`/notifications/${n.id}/read/`);
                      queryClient.invalidateQueries({ queryKey: ["notifications"] });
                    }}>
                      <div className="w-2 h-2 rounded-full bg-primary mt-2" />
                    </button>
                  )}
                </CardContent>
              </Card>
            ))
          ) : (
            <div className="text-center py-12 text-text-secondary">
              <Bell className="w-10 h-10 mx-auto mb-2 opacity-30" />
              <p className="text-sm">Bildirishnomalar yo'q</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function AppointmentCard({ apt, isDoctor, onConfirm, onCancel }: {
  apt: Appointment;
  isDoctor?: boolean;
  onConfirm?: () => void;
  onCancel?: () => void;
}) {
  const statusLabels: Record<string, { label: string; color: string }> = {
    pending: { label: "Kutilmoqda", color: "text-yellow-600 bg-yellow-50 border-yellow-200" },
    confirmed: { label: "Tasdiqlangan", color: "text-green-600 bg-green-50 border-green-200" },
    completed: { label: "Bajarilgan", color: "text-blue-600 bg-blue-50 border-blue-200" },
    cancelled: { label: "Bekor qilingan", color: "text-red-600 bg-red-50 border-red-200" },
  };
  const st = statusLabels[apt.status] || statusLabels.pending;

  return (
    <Card>
      <CardContent className="p-3">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-primary-light flex items-center justify-center flex-shrink-0">
            <Stethoscope className="w-5 h-5 text-primary" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div>
                <p className="font-medium text-sm">
                  {isDoctor
                    ? `${apt.patient_detail?.first_name || ""} ${apt.patient_detail?.last_name || ""}`.trim() || "Bemor"
                    : apt.doctor_detail?.full_name || `Shifokor #${apt.doctor}`}
                </p>
                <p className="text-xs text-text-secondary mt-0.5">
                  {formatDate(apt.appointment_date)} • {formatTime(apt.appointment_time)}
                </p>
              </div>
              <span className={`text-[10px] font-medium px-2 py-0.5 rounded-full border ${st.color} flex-shrink-0`}>
                {st.label}
              </span>
            </div>
            {apt.status === "pending" && onConfirm && (
              <div className="flex gap-2 mt-2">
                <Button size="sm" onClick={onConfirm}>
                  <CheckCircle className="w-3 h-3 mr-1" /> Tasdiqlash
                </Button>
                {onCancel && (
                  <Button size="sm" variant="outline" onClick={onCancel}>
                    <X className="w-3 h-3 mr-1" /> Bekor qilish
                  </Button>
                )}
              </div>
            )}
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

interface DoctorService {
  id: number; title: string; price: string; duration_minutes: number; description: string;
}

function ServicesManager({ queryClient }: { queryClient: ReturnType<typeof useQueryClient> }) {
  const { data: services, isLoading } = useQuery<DoctorService[]>({
    queryKey: ["doctor-services"],
    queryFn: async () => {
      const res = await api.get("/doctors/services/");
      return res.data;
    },
  });

  const [showForm, setShowForm] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);
  const [title, setTitle] = useState("");
  const [price, setPrice] = useState("");
  const [duration, setDuration] = useState("30");
  const [description, setDescription] = useState("");
  const [saving, setSaving] = useState(false);

  const resetForm = () => {
    setTitle(""); setPrice(""); setDuration("30"); setDescription("");
    setShowForm(false); setEditingId(null);
  };

  const handleEdit = (svc: DoctorService) => {
    setTitle(svc.title);
    setPrice(svc.price.toString());
    setDuration(svc.duration_minutes.toString());
    setDescription(svc.description);
    setEditingId(svc.id);
    setShowForm(true);
  };

  const handleSave = async () => {
    if (!title || !price) return;
    setSaving(true);
    try {
      const payload = { title, price, duration_minutes: parseInt(duration), description };
      if (editingId) {
        await api.patch(`/doctors/services/${editingId}/`, payload);
      } else {
        await api.post("/doctors/services/", payload);
      }
      queryClient.invalidateQueries({ queryKey: ["doctor-services"] });
      resetForm();
    } catch {}
    setSaving(false);
  };

  const handleDelete = async (id: number) => {
    if (!confirm("O'chirishni xohlaysizmi?")) return;
    try {
      await api.delete(`/doctors/services/${id}/`);
      queryClient.invalidateQueries({ queryKey: ["doctor-services"] });
    } catch {}
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-sm font-semibold">Xizmatlar</h2>
        <Button size="sm" onClick={() => { resetForm(); setShowForm(true); }}>
          <Plus className="w-4 h-4 mr-1" /> Qo'shish
        </Button>
      </div>

      {showForm && (
        <Card>
          <CardContent className="p-4 space-y-3">
            <input placeholder="Xizmat nomi" value={title} onChange={(e) => setTitle(e.target.value)}
              className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary" />
            <div className="grid grid-cols-2 gap-3">
              <input placeholder="Narxi (so'm)" type="number" value={price} onChange={(e) => setPrice(e.target.value)}
                className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary" />
              <input placeholder="Daqiqa" type="number" value={duration} onChange={(e) => setDuration(e.target.value)}
                className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary" />
            </div>
            <textarea placeholder="Tavsifi (ixtiyoriy)" value={description} onChange={(e) => setDescription(e.target.value)}
              className="w-full rounded-xl border border-border px-3 py-2 text-sm outline-none focus:border-primary resize-none h-20" />
            <div className="flex gap-2">
              <Button className="flex-1" onClick={handleSave} loading={saving}>
                {editingId ? "Yangilash" : "Qo'shish"}
              </Button>
              <Button variant="outline" onClick={resetForm}>Bekor qilish</Button>
            </div>
          </CardContent>
        </Card>
      )}

      {isLoading ? (
        <div className="space-y-2">
          {[1,2,3].map(i => <div key={i} className="h-16 bg-gray-100 rounded-xl animate-pulse" />)}
        </div>
      ) : services && services.length > 0 ? (
        <div className="space-y-2">
          {services.map((svc) => (
            <Card key={svc.id}>
              <CardContent className="p-3">
                <div className="flex items-start justify-between">
                  <div className="flex-1 min-w-0 mr-2">
                    <p className="font-medium text-sm">{svc.title}</p>
                    <p className="text-xs text-text-secondary">{svc.duration_minutes} daqiqa</p>
                    {svc.description && <p className="text-xs text-text-secondary mt-1">{svc.description}</p>}
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="font-bold text-sm text-primary">{formatPrice(parseFloat(svc.price))}</p>
                    <div className="flex gap-1 mt-1 justify-end">
                      <button onClick={() => handleEdit(svc)} className="text-xs text-primary">Tahrirlash</button>
                      <button onClick={() => handleDelete(svc.id)} className="text-xs text-danger">O'chirish</button>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        <div className="text-center py-8 text-text-secondary">
          <Star className="w-8 h-8 mx-auto mb-2 opacity-30" />
          <p className="text-sm">Xizmatlar mavjud emas</p>
          <p className="text-xs mt-1">Yuqoridagi "Qo'shish" tugmasini bosing</p>
        </div>
      )}
    </div>
  );
}

function QuickLink({ href, icon: Icon, label }: { href: string; icon: React.ElementType; label: string }) {
  return (
    <Link href={href} className="flex items-center justify-between p-3 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors">
      <div className="flex items-center gap-3">
        <Icon className="w-5 h-5 text-primary" />
        <span className="text-sm font-medium">{label}</span>
      </div>
      <ChevronRight className="w-4 h-4 text-text-secondary" />
    </Link>
  );
}
