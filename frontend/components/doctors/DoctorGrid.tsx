"use client";
import { DoctorCard } from "./DoctorCard";
import type { Doctor } from "@/types";
import { Stethoscope } from "lucide-react";
import Link from "next/link";

interface DoctorGridProps {
  doctors: Doctor[];
  title?: string;
  link?: string;
  loading?: boolean;
  emptyMessage?: string;
}

export function DoctorGrid({ doctors, title, link, loading, emptyMessage }: DoctorGridProps) {
  if (loading) {
    return (
      <section>
        {title && (
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-base font-bold">{title}</h2>
          </div>
        )}
        <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
          {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
            <div key={i} className="bg-surface rounded-2xl border border-border overflow-hidden animate-pulse">
              <div className="h-32 bg-gray-200" />
              <div className="p-3 space-y-2">
                <div className="h-3 bg-gray-200 rounded w-3/4" />
                <div className="h-2 bg-gray-200 rounded w-1/2" />
              </div>
            </div>
          ))}
        </div>
      </section>
    );
  }

  if (!doctors?.length) {
    if (emptyMessage) {
      return (
        <section>
          {title && <h2 className="text-base font-bold mb-3">{title}</h2>}
          <div className="text-center py-8 text-text-secondary">
            <Stethoscope className="w-10 h-10 mx-auto mb-2 opacity-30" />
            <p className="text-sm">{emptyMessage}</p>
          </div>
        </section>
      );
    }
    return null;
  }

  return (
    <section>
      {title && (
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-base font-bold">{title}</h2>
          {link && (
            <Link href={link} className="text-xs text-primary font-medium">Barchasi</Link>
          )}
        </div>
      )}
      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
        {doctors.map((doctor) => (
          <DoctorCard key={doctor.id} doctor={doctor} />
        ))}
      </div>
    </section>
  );
}
