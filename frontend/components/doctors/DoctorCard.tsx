"use client";
import Link from "next/link";
import { Star, MapPin, Stethoscope } from "lucide-react";
import type { Doctor } from "@/types";
import { formatRating } from "@/utils";

interface DoctorCardProps {
  doctor: Doctor;
}

export function DoctorCard({ doctor }: DoctorCardProps) {
  return (
    <Link href={`/doctors/${doctor.id}`}>
      <div className="bg-surface rounded-2xl border border-border shadow-sm hover:shadow-md transition-all duration-200 overflow-hidden group">
        <div className="relative h-32 bg-gradient-to-br from-primary-light to-secondary/10 flex items-center justify-center overflow-hidden">
          {doctor.image ? (
            <img
              src={doctor.image}
              alt={doctor.full_name}
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            />
          ) : (
            <Stethoscope className="w-12 h-12 text-primary/40" />
          )}
          {doctor.distance_km && (
            <span className="absolute top-2 left-2 bg-white/90 backdrop-blur-sm text-xs font-medium px-2 py-0.5 rounded-full shadow-sm">
              {doctor.distance_km} km
            </span>
          )}
        </div>

        <div className="p-3 space-y-2">
          <div>
            <h3 className="font-semibold text-sm text-text leading-tight line-clamp-1">{doctor.full_name}</h3>
            <p className="text-xs text-text-secondary line-clamp-1">{doctor.specializations.map((s) => s.name).join(", ")}</p>
          </div>

          <div className="flex items-center justify-between">
            <div className="flex items-center gap-1">
              <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" />
              <span className="text-xs font-semibold">{formatRating(doctor.avg_rating)}</span>
              <span className="text-[10px] text-text-secondary">({doctor.review_count})</span>
            </div>
            <span className="text-[10px] text-text-secondary">{doctor.experience_years} yil</span>
          </div>

          <div className="flex items-center gap-1 text-[10px] text-text-secondary">
            <MapPin className="w-3 h-3 flex-shrink-0" />
            <span className="truncate">{doctor.clinic_name}</span>
          </div>

          <div className="flex items-center justify-between pt-1">
            <span className="text-sm font-bold text-primary">
              {new Intl.NumberFormat("en-US", { style: "currency", currency: "UZS", maximumFractionDigits: 0, currencyDisplay: "narrowSymbol" }).format(
                parseFloat(doctor.consultation_price)
              )}
            </span>
            <span className="text-[10px] font-medium text-primary bg-primary-light px-2.5 py-1 rounded-full">
              Yozilish
            </span>
          </div>
        </div>
      </div>
    </Link>
  );
}
