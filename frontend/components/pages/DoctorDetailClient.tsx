"use client";
import { useState, useMemo } from "react";
import { useParams, useRouter } from "next/navigation";
import { useDoctor, useAvailableTimes } from "@/hooks/useDoctors";
import { useCreateAppointment } from "@/hooks/useAppointments";
import { useAddFavorite, useRemoveFavorite } from "@/hooks/useFavorites";
import { useGetOrCreateRoom } from "@/hooks/useChat";
import { useAuthStore } from "@/stores/authStore";
import { useDoctorReviews, useCreateReview, useCheckReview } from "@/hooks/useReviews";
import { Button } from "@/components/ui/Button";
import { Badge } from "@/components/ui/Badge";
import { Card, CardContent } from "@/components/ui/Card";
import { StarRating } from "@/components/ui/StarRating";
import { StarBreakdown } from "@/components/ui/StarBreakdown";
import {
  Star, MapPin, MessageCircle, Heart, Calendar, Stethoscope,
  Clock, ChevronLeft, Navigation, Award, Users, PenLine
} from "lucide-react";
import Link from "next/link";
import { formatRating, formatPrice, formatDate, formatTime } from "@/utils";
import { Swiper, SwiperSlide } from "swiper/react";
import { Pagination, A11y } from "swiper/modules";
import "swiper/css";
import "swiper/css/pagination";

export default function DoctorDetailClient() {
  const { id } = useParams<{ id: string }>();
  const doctorId = parseInt(id);
  const { data: doctor, isLoading } = useDoctor(doctorId);
  const user = useAuthStore((s) => s.user);
  const addFavorite = useAddFavorite();
  const removeFavorite = useRemoveFavorite();
  const getOrCreateRoom = useGetOrCreateRoom();
  const createAppointment = useCreateAppointment();
  const { data: reviews } = useDoctorReviews(doctorId);
  const { data: reviewCheck } = useCheckReview(doctorId);
  const createReview = useCreateReview();

  const [selectedDate, setSelectedDate] = useState("");
  const [selectedSlotId, setSelectedSlotId] = useState<number | null>(null);
  const [showBooking, setShowBooking] = useState(false);
  const [newRating, setNewRating] = useState(0);
  const [newComment, setNewComment] = useState("");
  const [showReviewForm, setShowReviewForm] = useState(false);
  const today = new Date().toISOString().split("T")[0];
  const { data: slots } = useAvailableTimes(doctorId, selectedDate);
  const router = useRouter();

  const confirmedSlot = useMemo(() => {
    if (!selectedSlotId || !slots) return null;
    return slots.find((s) => s.id === selectedSlotId) || null;
  }, [selectedSlotId, slots]);

  const handleChat = async () => {
    if (!user) return router.push("/auth/login");
    try {
      const room = await getOrCreateRoom.mutateAsync(doctorId);
      router.push(`/chat/${room.id}`);
    } catch {}
  };

  const handleBook = async () => {
    if (!selectedSlotId || !confirmedSlot || !user) return;
    if (confirmedSlot.status !== "available") return;
    try {
      await createAppointment.mutateAsync({
        doctor: doctorId,
        appointment_date: confirmedSlot.date,
        appointment_time: confirmedSlot.start_time,
      });
      setShowBooking(false);
      setSelectedDate("");
      setSelectedSlotId(null);
      router.push("/appointments");
    } catch {}
  };

  const handleSubmitReview = async () => {
    if (newRating === 0 || !user) return;
    try {
      await createReview.mutateAsync({
        doctor: doctorId,
        rating: newRating,
        comment: newComment || undefined,
      });
      setNewRating(0);
      setNewComment("");
      setShowReviewForm(false);
    } catch {}
  };

  const statusColor = (status: string) => {
    switch (status) {
      case "available": return "bg-green-100 text-green-700 border-green-300 hover:bg-green-200";
      case "blocked": return "bg-yellow-100 text-yellow-700 border-yellow-300 cursor-not-allowed opacity-70";
      case "booked": return "bg-red-100 text-red-700 border-red-300 cursor-not-allowed opacity-70";
      default: return "border-border text-text";
    }
  };

  const statusLabel = (status: string) => {
    switch (status) {
      case "available": return "Bo'sh";
      case "blocked": return "Bloklangan";
      case "booked": return "Band";
      default: return status;
    }
  };

  if (isLoading) {
    return (
      <div className="animate-pulse">
        <div className="h-64 bg-gray-200" />
        <div className="p-4 space-y-4">
          <div className="h-6 bg-gray-200 rounded w-1/3" />
          <div className="h-4 bg-gray-200 rounded w-2/3" />
        </div>
      </div>
    );
  }

  if (!doctor) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] px-4">
        <Stethoscope className="w-16 h-16 text-text-secondary/30 mb-4" />
        <h2 className="text-lg font-semibold">Shifokor topilmadi</h2>
        <p className="text-text-secondary text-sm mt-1 text-center">Bu shifokor hozircha mavjud emas yoki faol emas</p>
        <Link href="/" className="text-primary text-sm mt-4 font-medium">Bosh sahifaga qaytish</Link>
      </div>
    );
  }

  const breakdownTotal = Object.values(doctor.rating_breakdown || {}).reduce((s, v) => s + v.count, 0);

  return (
    <div className="max-w-4xl mx-auto">
      {/* Header Image */}
      <div className="relative h-52 bg-gradient-to-br from-primary-light via-primary/5 to-secondary/10">
        <button onClick={() => router.back()} className="absolute top-4 left-4 w-9 h-9 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-sm">
          <ChevronLeft className="w-5 h-5" />
        </button>
        <div className="absolute -bottom-12 left-4 w-24 h-24 rounded-2xl bg-surface border-2 border-surface shadow-md overflow-hidden">
          {doctor.image ? (
            <img src={doctor.image} alt={doctor.full_name} className="w-full h-full object-cover" />
          ) : (
            <div className="w-full h-full flex items-center justify-center bg-primary-light">
              <Stethoscope className="w-8 h-8 text-primary" />
            </div>
          )}
        </div>
        {user?.role === "patient" && (
          <button
            onClick={() => doctor.is_favorited ? removeFavorite.mutate(doctorId) : addFavorite.mutate(doctorId)}
            className="absolute top-4 right-4 w-9 h-9 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-sm"
          >
            <Heart className={`w-5 h-5 ${doctor.is_favorited ? "fill-danger text-danger" : "text-text-secondary"}`} />
          </button>
        )}
      </div>

      {/* Doctor Info */}
      <div className="px-4 pt-14 pb-4 space-y-4">
        <div>
          <h1 className="text-xl font-bold">{doctor.full_name}</h1>
          <p className="text-sm text-text-secondary">{doctor.specializations.map((s) => s.name).join(", ")}</p>
        </div>

        <div className="flex items-center gap-4 flex-wrap">
          <div className="flex items-center gap-1">
            <StarRating rating={doctor.avg_rating} size="sm" disabled />
            <span className="font-semibold text-sm ml-1">{formatRating(doctor.avg_rating)}</span>
            <span className="text-xs text-text-secondary">({doctor.review_count})</span>
          </div>
          <div className="flex items-center gap-1 text-xs text-text-secondary">
            <Award className="w-3.5 h-3.5" />
            {doctor.experience_years} yillik tajriba
          </div>
          <Badge variant={doctor.clinic?.is_24_7 ? "success" : "info"}>
            {doctor.clinic?.is_24_7 ? "24/7" : "Ish vaqti"}
          </Badge>
        </div>

        <div className="flex items-center gap-2 text-sm text-text-secondary">
          <MapPin className="w-4 h-4 text-primary flex-shrink-0" />
          <span>{doctor.clinic_name} — {doctor.clinic_address}</span>
        </div>

        {doctor.distance_km && (
          <div className="flex items-center gap-2 text-sm text-text-secondary">
            <Navigation className="w-4 h-4 text-primary flex-shrink-0" />
            <span>Sizdan {doctor.distance_km} km uzoqlikda</span>
          </div>
        )}

        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={handleChat}>
            <MessageCircle className="w-4 h-4 mr-1" /> Chat
          </Button>
          <a href={`https://www.google.com/maps/dir/?api=1&destination=${doctor.clinic.latitude},${doctor.clinic.longitude}`} target="_blank" rel="noopener noreferrer">
            <Button variant="outline" size="sm">
              <Navigation className="w-4 h-4 mr-1" /> Yo'nalish
            </Button>
          </a>
        </div>
      </div>

      {/* About */}
      {doctor.bio && (
        <div className="px-4 py-4">
          <h2 className="font-semibold text-base mb-2">Haqida</h2>
          <p className="text-sm text-text-secondary leading-relaxed">{doctor.bio}</p>
        </div>
      )}

      {/* Ratings & Reviews */}
      <div className="px-4 py-4 border-t border-border">
        <h2 className="font-semibold text-base mb-4">Reyting va sharhlar</h2>

        <div className="flex gap-6 items-start mb-4">
          <div className="text-center flex-shrink-0">
            <div className="text-4xl font-bold text-text">{formatRating(doctor.avg_rating)}</div>
            <StarRating rating={doctor.avg_rating} size="sm" disabled />
            <p className="text-xs text-text-secondary mt-1">{doctor.review_count} ta sharh</p>
          </div>
          <div className="flex-1">
            <StarBreakdown breakdown={doctor.rating_breakdown || {}} total={breakdownTotal} />
          </div>
        </div>

        {/* Add Review */}
        {user?.role === "patient" && (
          <div className="mb-4">
            {!reviewCheck?.has_reviewed && !showReviewForm ? (
              <Button variant="outline" size="sm" onClick={() => setShowReviewForm(true)}>
                <PenLine className="w-4 h-4 mr-1" /> Sharh qoldirish
              </Button>
            ) : showReviewForm ? (
              <Card>
                <CardContent className="p-4 space-y-3">
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium">Baholang:</span>
                    <StarRating rating={newRating} onChange={setNewRating} size="md" />
                  </div>
                  <textarea
                    placeholder="Sharhingiz (ixtiyoriy)"
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary resize-none h-20"
                  />
                  <div className="flex gap-2">
                    <Button size="sm" onClick={handleSubmitReview} loading={createReview.isPending} disabled={newRating === 0}>
                      Yuborish
                    </Button>
                    <Button variant="outline" size="sm" onClick={() => { setShowReviewForm(false); setNewRating(0); setNewComment(""); }}>
                      Bekor qilish
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ) : null}
          </div>
        )}

        {/* Review List */}
        {reviews && reviews.length > 0 ? (
          <div className="space-y-3">
            {reviews.map((review) => (
              <Card key={review.id}>
                <CardContent className="p-3">
                  <div className="flex items-center justify-between mb-1">
                    <p className="text-sm font-medium">{review.user_detail?.first_name} {review.user_detail?.last_name}</p>
                    <span className="text-xs text-text-secondary">{formatDate(review.created_at)}</span>
                  </div>
                  <StarRating rating={review.rating} size="sm" disabled />
                  {review.comment && <p className="text-sm text-text-secondary mt-1">{review.comment}</p>}
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <p className="text-sm text-text-secondary text-center py-4">Hali sharhlar mavjud emas</p>
        )}
      </div>

      {/* Services - Swiper */}
      {doctor.services.length > 0 && (
        <div className="px-4 py-4 border-t border-border">
          <h2 className="font-semibold text-base mb-3">Xizmatlar</h2>
          <Swiper
            modules={[Pagination, A11y]}
            spaceBetween={12}
            slidesPerView="auto"
            pagination={{ clickable: true }}
            className="!pb-8"
          >
            {doctor.services.map((service) => (
              <SwiperSlide key={service.id} className="!w-48">
                <Card className="h-full">
                  <CardContent className="p-4 flex flex-col h-full">
                    <p className="font-semibold text-sm text-text">{service.title}</p>
                    <p className="text-xs text-text-secondary mt-1 line-clamp-2">{service.description || service.duration_minutes + " daqiqa"}</p>
                    <div className="mt-auto pt-2">
                      <p className="font-bold text-base text-primary">
                        {formatPrice(service.price)}
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </SwiperSlide>
            ))}
          </Swiper>
        </div>
      )}

      {/* Map */}
      {doctor.clinic?.latitude && doctor.clinic?.longitude && (
        <div className="px-4 py-4 border-t border-border">
          <h2 className="font-semibold text-base mb-3">Manzil</h2>
          <a
            href={`https://www.google.com/maps/dir/?api=1&destination=${doctor.clinic.latitude},${doctor.clinic.longitude}`}
            target="_blank"
            rel="noopener noreferrer"
            className="block h-40 bg-gradient-to-br from-primary-light to-secondary/5 rounded-2xl border border-border flex items-center justify-center"
          >
            <div className="text-center">
              <MapPin className="w-8 h-8 text-primary mx-auto mb-1" />
              <span className="text-sm text-primary font-medium">Xaritada ochish</span>
            </div>
          </a>
        </div>
      )}

      {/* Booking Modal */}
      {showBooking && user && (
        <div className="fixed inset-0 z-50 bg-black/40 flex items-end sm:items-center justify-center" onClick={() => setShowBooking(false)}>
          <div className="bg-surface rounded-t-3xl sm:rounded-3xl w-full max-w-md max-h-[80vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
            <div className="p-4 border-b border-border flex items-center justify-between">
              <h3 className="font-semibold">Qabulga yozilish</h3>
              <button onClick={() => setShowBooking(false)} className="text-text-secondary text-sm">Yopish</button>
            </div>
            <div className="p-4 space-y-4">
              <div>
                <label className="block text-sm font-medium text-text mb-2">Sanani tanlang</label>
                <input
                  type="date"
                  min={today}
                  value={selectedDate}
                  onChange={(e) => { setSelectedDate(e.target.value); setSelectedSlotId(null); }}
                  className="w-full rounded-2xl border border-border px-4 py-2.5 text-sm outline-none focus:border-primary"
                />
              </div>

              <div className="flex gap-4 text-xs">
                <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-green-100 border border-green-300" /> Bo'sh</span>
                <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-yellow-100 border border-yellow-300" /> Bloklangan</span>
                <span className="flex items-center gap-1"><span className="w-3 h-3 rounded bg-red-100 border border-red-300" /> Band</span>
              </div>

              {selectedDate && slots && (
                <div>
                  {slots.length > 0 ? (
                    <div className="grid grid-cols-3 gap-2">
                      {slots.map((slot) => {
                        const isAvailable = slot.status === "available";
                        const isSelected = selectedSlotId === slot.id;
                        return (
                          <button
                            key={slot.id}
                            onClick={() => {
                              if (!isAvailable) return;
                              setSelectedSlotId(isSelected ? null : slot.id);
                            }}
                            className={`py-2.5 rounded-2xl text-sm font-medium border transition-colors ${
                              isSelected
                                ? "bg-pink-100 text-pink-700 border-pink-400 ring-2 ring-pink-300"
                                : statusColor(slot.status)
                            }`}
                          >
                            <div>{slot.start_time.slice(0, 5)}</div>
                            <div className="text-[10px] opacity-75">{statusLabel(slot.status)}</div>
                          </button>
                        );
                      })}
                    </div>
                  ) : (
                    <p className="text-sm text-text-secondary text-center py-6">Bu sana uchun vaqtlar mavjud emas</p>
                  )}
                </div>
              )}

              {!selectedDate && (
                <p className="text-sm text-text-secondary text-center py-6">Iltimos, sanani tanlang</p>
              )}

              {selectedSlotId && confirmedSlot?.status === "available" ? (
                <Button
                  className="w-full !bg-primary !text-white !py-4 !text-base !font-bold"
                  onClick={handleBook}
                  loading={createAppointment.isPending}
                >
                  Qabulga yozilish
                </Button>
              ) : (
                <Button
                  className="w-full"
                  disabled
                >
                  {selectedDate ? "Vaqtni tanlang" : "Sanani tanlang"}
                </Button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Fixed Bottom CTA */}
      <div className="sticky bottom-16 bg-surface border-t border-border px-4 py-3 flex gap-3">
        <Button variant="outline" className="flex-1" onClick={handleChat}>
          <MessageCircle className="w-4 h-4 mr-1" /> Chat
        </Button>
        <Button className="flex-1" onClick={() => {
          if (!user) return router.push("/auth/login");
          setShowBooking(true);
        }}>
          <Calendar className="w-4 h-4 mr-1" /> Yozilish
        </Button>
      </div>
    </div>
  );
}
