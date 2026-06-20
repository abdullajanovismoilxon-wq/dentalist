"use client";
import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { useClinic, useClinicReviews, useCreateClinicReview, useCheckClinicReview } from "@/hooks/useClinics";
import { useDoctors } from "@/hooks/useDoctors";
import { Swiper, SwiperSlide } from "swiper/react";
import { Pagination, Navigation, A11y, Autoplay } from "swiper/modules";
import "swiper/css";
import "swiper/css/pagination";
import "swiper/css/navigation";
import { Star, MapPin, Phone, Clock, Building2, ChevronLeft, Stethoscope, Calendar, PenLine } from "lucide-react";
import Link from "next/link";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { StarRating } from "@/components/ui/StarRating";
import { useAuthStore } from "@/stores/authStore";
import { formatRating, formatDate } from "@/utils";
import type { Doctor } from "@/types";

export default function ClinicDetailClient() {
  const { id } = useParams<{ id: string }>();
  const clinicId = parseInt(id);
  const { data: clinic, isLoading } = useClinic(clinicId);
  const { data: reviews } = useClinicReviews(clinicId);
  const { data: reviewCheck } = useCheckClinicReview(clinicId);
  const createReview = useCreateClinicReview();
  const { data: doctors, isLoading: doctorsLoading } = useDoctors({ clinic_id: id });
  const user = useAuthStore((s) => s.user);
  const router = useRouter();
  const [showAllDoctors, setShowAllDoctors] = useState(false);
  const [showReviewForm, setShowReviewForm] = useState(false);
  const [newRating, setNewRating] = useState(5);
  const [newComment, setNewComment] = useState("");

  if (isLoading) {
    return (
      <div className="max-w-4xl mx-auto px-4 pt-4 pb-4 space-y-4 animate-pulse">
        <div className="h-56 bg-gray-200 rounded-2xl" />
        <div className="h-8 bg-gray-200 rounded w-2/3" />
        <div className="h-4 bg-gray-200 rounded w-1/3" />
        <div className="h-4 bg-gray-200 rounded w-1/2" />
        <div className="grid grid-cols-2 gap-3">
          <div className="h-40 bg-gray-100 rounded-2xl" />
          <div className="h-40 bg-gray-100 rounded-2xl" />
        </div>
      </div>
    );
  }

  if (!clinic) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] text-text-secondary">
        <Building2 className="w-16 h-16 mb-4 opacity-30" />
        <p className="text-sm">Klinika topilmadi</p>
        <Link href="/" className="text-primary text-sm mt-2 font-medium">Bosh sahifa</Link>
      </div>
    );
  }

  const hasGallery = Array.isArray(clinic.gallery) && clinic.gallery.length > 0;
  const displayedDoctors = showAllDoctors ? doctors : doctors?.slice(0, 4);

  return (
    <div className="max-w-4xl mx-auto pb-4">
      {/* Clinic Avatar Header (single image) */}
      <div className="relative">
        {clinic.image ? (
          <div className="w-full h-56 md:h-80 bg-gray-100">
            <img src={clinic.image} alt={clinic.name} className="w-full h-full object-cover" />
          </div>
        ) : (
          <div className="w-full h-56 md:h-80 bg-gradient-to-br from-primary-light to-secondary/10 flex items-center justify-center">
            <Building2 className="w-16 h-16 text-primary/40" />
          </div>
        )}
        <button onClick={() => router.back()} className="absolute top-4 left-4 w-9 h-9 bg-white/90 backdrop-blur-sm rounded-full flex items-center justify-center shadow-sm z-10">
          <ChevronLeft className="w-5 h-5" />
        </button>
      </div>

      {/* Clinic Info */}
      <div className="px-4 mt-4 space-y-3">
        <h1 className="text-xl font-bold">{clinic.name}</h1>

        <div className="flex items-center gap-4 flex-wrap text-sm">
          <div className="flex items-center gap-1">
            <Star className="w-4 h-4 text-amber-400 fill-amber-400" />
            <span className="font-semibold">{formatRating(clinic.avg_rating)}</span>
            <span className="text-text-secondary">({clinic.review_count} ta baho)</span>
          </div>
          {clinic.doctors_count > 0 && (
            <span className="text-text-secondary">{clinic.doctors_count} ta shifokor</span>
          )}
        </div>

        {clinic.address && (
          <div className="flex items-start gap-2 text-sm">
            <MapPin className="w-4 h-4 text-primary mt-0.5 flex-shrink-0" />
            <span>{clinic.address}</span>
          </div>
        )}

        {clinic.phone && (
          <div className="flex items-center gap-2 text-sm">
            <Phone className="w-4 h-4 text-primary flex-shrink-0" />
            <a href={`tel:${clinic.phone}`} className="hover:text-primary">{clinic.phone}</a>
          </div>
        )}

        {clinic.description && (
          <p className="text-sm text-text-secondary leading-relaxed">{clinic.description}</p>
        )}

        {clinic.is_24_7 && (
          <div className="flex items-center gap-2 text-sm text-primary">
            <Clock className="w-4 h-4" />
            <span className="font-medium">24/7 ishlaydi</span>
          </div>
        )}
      </div>

      {/* Doctors Section */}
      <div className="px-4 mt-6">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-bold">Shifokorlar</h2>
          {doctors && doctors.length > 4 && (
            <button onClick={() => setShowAllDoctors(!showAllDoctors)} className="text-xs text-primary font-medium">
              {showAllDoctors ? "Yopish" : `Barchasi (${doctors.length})`}
            </button>
          )}
        </div>

        {doctorsLoading ? (
          <div className="grid grid-cols-2 gap-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="bg-surface rounded-2xl border border-border animate-pulse">
                <div className="h-28 bg-gray-200 rounded-t-2xl" />
                <div className="p-3 space-y-2">
                  <div className="h-3 bg-gray-200 rounded w-2/3" />
                  <div className="h-2 bg-gray-200 rounded w-1/2" />
                  <div className="h-2 bg-gray-200 rounded w-1/3" />
                </div>
              </div>
            ))}
          </div>
        ) : displayedDoctors && displayedDoctors.length > 0 ? (
          <div className="space-y-3">
            {displayedDoctors.map((doc: Doctor) => (
              <Card key={doc.id} className="overflow-hidden">
                <div className="flex">
                  <Link href={`/doctors/${doc.id}`} className="flex-shrink-0 w-24 h-24 bg-gradient-to-br from-primary-light to-secondary/10 flex items-center justify-center overflow-hidden">
                    {doc.image ? (
                      <img src={doc.image} alt={doc.full_name} className="w-full h-full object-cover" />
                    ) : (
                      <Stethoscope className="w-8 h-8 text-primary/40" />
                    )}
                  </Link>
                  <div className="flex-1 min-w-0 p-3 flex flex-col justify-between">
                    <Link href={`/doctors/${doc.id}`}>
                      <h3 className="font-semibold text-sm text-text leading-tight">{doc.full_name}</h3>
                      <p className="text-xs text-text-secondary mt-0.5 line-clamp-1">{doc.specializations.map((s) => s.name).join(", ")}</p>
                    </Link>
                    <div className="flex items-center justify-between mt-1">
                      <div className="flex items-center gap-1">
                        <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" />
                        <span className="text-xs font-semibold">{formatRating(doc.avg_rating)}</span>
                        <span className="text-[10px] text-text-secondary">({doc.review_count})</span>
                      </div>
                      <Button size="sm" className="!py-1 !px-3 text-xs" onClick={() => router.push(`/doctors/${doc.id}`)}>
                        <Calendar className="w-3 h-3 mr-1" /> Yozilish
                      </Button>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <div className="text-center py-8 text-text-secondary">
            <Stethoscope className="w-8 h-8 mx-auto mb-2 opacity-30" />
            <p className="text-sm">Bu klinikada hozircha shifokor yo'q</p>
          </div>
        )}
      </div>

      {/* Gallery Swiper */}
      {hasGallery && (
        <div className="px-4 mt-6">
          <h2 className="text-base font-bold mb-3">Galereya</h2>
          <Swiper
            modules={[Pagination, A11y, Autoplay]}
            spaceBetween={12}
            slidesPerView="auto"
            pagination={{ clickable: true }}
            autoplay={{ delay: 4000, disableOnInteraction: false }}
            className="!pb-8"
          >
            {clinic.gallery.map((img) => (
              <SwiperSlide key={img.id} className="!w-56">
                <div className="h-36 rounded-2xl overflow-hidden bg-gray-100">
                  <img src={img.image} alt="" className="w-full h-full object-cover" />
                </div>
              </SwiperSlide>
            ))}
          </Swiper>
        </div>
      )}

      {/* Reviews Section */}
      <div className="px-4 mt-6">
        <h2 className="text-base font-bold mb-3">Baho va sharhlar</h2>

        {/* Add Review */}
        {user?.role === "patient" && (
          <div className="mb-4">
            {!reviewCheck?.has_reviewed && !showReviewForm ? (
              <Button variant="outline" size="sm" onClick={() => setShowReviewForm(true)}>
                <PenLine className="w-4 h-4 mr-1" /> Baholash
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
                    <Button size="sm" onClick={async () => {
                      await createReview.mutateAsync({ clinicId, rating: newRating, comment: newComment || undefined });
                      setNewRating(5);
                      setNewComment("");
                      setShowReviewForm(false);
                    }} loading={createReview.isPending} disabled={newRating === 0}>
                      Yuborish
                    </Button>
                    <Button variant="outline" size="sm" onClick={() => { setShowReviewForm(false); setNewRating(5); setNewComment(""); }}>
                      Bekor qilish
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ) : null}
          </div>
        )}

        {reviews && reviews.length > 0 ? (
          <div className="flex gap-3 overflow-x-auto scrollbar-hide -mx-4 px-4 pb-1">
            {reviews.map((review) => (
              <Card key={review.id} className="flex-shrink-0 w-64">
                <CardContent className="p-4">
                  <div className="flex items-center gap-2 mb-2">
                    <div className="w-8 h-8 rounded-full bg-primary-light flex items-center justify-center">
                      <span className="text-xs font-bold text-primary">
                        {(review.user_detail?.first_name?.[0] || "U").toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <p className="text-sm font-semibold">
                        {review.user_detail?.first_name || "Foydalanuvchi"}
                      </p>
                      <div className="flex items-center gap-0.5">
                        {Array.from({ length: 5 }, (_, i) => (
                          <Star
                            key={i}
                            className={`w-3 h-3 ${i < review.rating ? "text-amber-400 fill-amber-400" : "text-gray-300"}`}
                          />
                        ))}
                      </div>
                      <p className="text-[10px] text-text-secondary">{formatDate(review.created_at)}</p>
                    </div>
                  </div>
                  {review.comment && (
                    <p className="text-xs text-text-secondary leading-relaxed line-clamp-3">{review.comment}</p>
                  )}
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <p className="text-sm text-text-secondary text-center py-4">Hali sharhlar mavjud emas</p>
        )}
      </div>
    </div>
  );
}
