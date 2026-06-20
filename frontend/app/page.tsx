"use client";
import { useEffect, useState } from "react";
import { DoctorGrid } from "@/components/doctors/DoctorGrid";
import { useDoctors, useNearbyDoctors } from "@/hooks/useDoctors";
import { useClinics } from "@/hooks/useClinics";
import { useSearch } from "@/hooks/useSearch";
import { Card, CardContent } from "@/components/ui/Card";
import { Star, MapPin, Building2 } from "lucide-react";
import Link from "next/link";
import { Swiper, SwiperSlide } from "swiper/react";
import { Pagination, A11y, Autoplay } from "swiper/modules";
import "swiper/css";
import "swiper/css/pagination";

export default function HomePage() {
  const [coords, setCoords] = useState<{ lat: string; lng: string } | null>(null);
  const [activeFilter, setActiveFilter] = useState("Barchasi");
  const [specializations, setSpecializations] = useState<{ id: number; name: string }[]>([]);

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => setCoords({ lat: pos.coords.latitude.toString(), lng: pos.coords.longitude.toString() }),
        () => {}
      );
    }
    fetch(`${process.env.NEXT_PUBLIC_API_URL}/doctors/specializations/`)
      .then((r) => r.json())
      .then((data) => {
        const list = Array.isArray(data?.results) ? data.results : Array.isArray(data) ? data : [];
        setSpecializations(list);
      })
      .catch(() => {});
  }, []);

  const filterParams: Record<string, string> = {};
  if (activeFilter === "Ayol doktor") filterParams.gender = "female";
  else if (activeFilter === "24/7") filterParams.is_24_7 = "true";
  else if (activeFilter === "Eng yaqin") { if (coords) { filterParams.lat = coords.lat; filterParams.lng = coords.lng; } }
  else if (activeFilter === "Eng yaxshi") filterParams.ordering = "-avg_rating";
  else if (activeFilter === "Bolalar") filterParams.patient_type = "children";
  else if (activeFilter !== "Barchasi") filterParams.specialization = activeFilter;

  const { data: doctors, isLoading } = useDoctors(
    Object.keys(filterParams).length > 0 ? filterParams : undefined
  );

  const { data: nearby, isLoading: nearbyLoading } = useNearbyDoctors(
    coords ? { lat: coords.lat, lng: coords.lng } : { lat: "41.2995", lng: "69.2401" }
  );

  const { data: topRated, isLoading: topLoading } = useDoctors({ ordering: "-avg_rating" });
  const { data: femaleDoctors, isLoading: femaleLoading } = useDoctors({ gender: "female" });
  const { data: roundClock, isLoading: clockLoading } = useDoctors({ is_24_7: "true" });
  const { data: clinics, isLoading: clinicsLoading } = useClinics({ ordering: "-avg_rating" });

  const safeSpecs = Array.isArray(specializations) ? specializations : [];
  const filterChips = [
    "Barchasi", "Ayol doktor", "24/7", "Eng yaqin", "Bolalar",
  ];

  return (
    <div className="max-w-7xl mx-auto space-y-6 px-4 pt-4 pb-4">
      {/* Filter Chips */}
      <div className="flex gap-2 overflow-x-auto scrollbar-hide -mx-4 px-4 pb-1">
        {filterChips.map((f) => (
          <button
            key={f}
            onClick={() => setActiveFilter(f)}
            className={`whitespace-nowrap px-4 py-2 rounded-full text-sm font-medium transition-all border flex-shrink-0 ${
              f === "Ayol doktor" && activeFilter === f
                ? "bg-[#E056C5] text-white border-[#E056C5] shadow-sm"
                : f === "Ayol doktor"
                  ? "bg-pink-50 text-[#E056C5] border-[#E056C5] hover:bg-pink-100"
                  : activeFilter === f
                    ? "bg-primary text-white border-primary shadow-sm"
                    : "bg-surface text-text-secondary border-border hover:border-primary/30"
            }`}
          >
            {f}
          </button>
        ))}
      </div>

      {/* Filtered Doctors */}
      {activeFilter !== "Barchasi" && (
        <DoctorGrid
          doctors={doctors || []}
          title={activeFilter}
          loading={isLoading}
          emptyMessage="Bu filter bo'yicha shifokor topilmadi"
        />
      )}

      {/* Nearby Doctors */}
      <DoctorGrid
        doctors={nearby || []}
        title="Eng yaqin shifokorlar"
        loading={nearbyLoading}
      />

      {/* Popular Clinics - Swiper */}
      <section>
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-bold">Mashhur klinikalar</h2>
          <Link href="/search" className="text-xs text-primary font-medium">Barchasi</Link>
        </div>
        {clinicsLoading ? (
          <div className="flex gap-3 overflow-x-auto scrollbar-hide -mx-4 px-4 pb-1">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex-shrink-0 w-44 animate-pulse">
                <div className="h-24 bg-gray-200 rounded-2xl" />
                <div className="p-3 space-y-2">
                  <div className="h-4 bg-gray-200 rounded w-3/4" />
                  <div className="h-3 bg-gray-200 rounded w-1/2" />
                </div>
              </div>
            ))}
          </div>
        ) : (
          <Swiper
            modules={[Pagination, A11y, Autoplay]}
            spaceBetween={12}
            slidesPerView="auto"
            pagination={{ clickable: true }}
            autoplay={{ delay: 4000, disableOnInteraction: false }}
            className="!pb-8"
          >
            {clinics?.slice(0, 5).map((clinic) => (
              <SwiperSlide key={clinic.id} className="!w-44">
                <Link href={`/clinics/${clinic.id}`}>
                  <Card className="w-full">
                    <CardContent className="p-0">
                      <div className="h-24 bg-gradient-to-br from-primary-light to-secondary/10 rounded-t-2xl flex items-center justify-center overflow-hidden">
                        {clinic.image ? (
                          <img src={clinic.image} alt={clinic.name} className="w-full h-full object-cover" />
                        ) : (
                          <Building2 className="w-8 h-8 text-primary/40" />
                        )}
                      </div>
                      <div className="p-3">
                        <h3 className="font-semibold text-sm truncate">{clinic.name}</h3>
                        <div className="flex items-center gap-1 mt-1">
                          <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                          <span className="text-xs font-medium">{clinic.avg_rating}</span>
                          <span className="text-xs text-text-secondary">({clinic.review_count})</span>
                        </div>
                        {clinic.doctors_count > 0 && (
                          <p className="text-xs text-text-secondary mt-0.5">{clinic.doctors_count} ta shifokor</p>
                        )}
                      </div>
                    </CardContent>
                  </Card>
                </Link>
              </SwiperSlide>
            ))}
          </Swiper>
        )}
      </section>

      {/* Top Doctors - Grid */}
      <DoctorGrid
        doctors={topRated?.slice(0, 8) || []}
        title="Eng yaxshi shifokorlar"
        link="/search?sort=rating"
        loading={topLoading}
      />

      {/* 24/7 Doctors */}
      <DoctorGrid
        doctors={roundClock?.slice(0, 4) || []}
        title="24/7 ishlaydigan"
        loading={clockLoading}
      />

      {/* Female Doctors */}
      <DoctorGrid
        doctors={femaleDoctors?.slice(0, 4) || []}
        title="Ayol shifokorlar"
        link="/search?gender=female"
        loading={femaleLoading}
      />
    </div>
  );
}
