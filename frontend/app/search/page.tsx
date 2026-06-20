"use client";
import { useState } from "react";
import { useSearchParams } from "next/navigation";
import { useSearch } from "@/hooks/useSearch";
import { DoctorGrid } from "@/components/doctors/DoctorGrid";
import { Search, MapPin, Stethoscope } from "lucide-react";

type Tab = "doctors" | "clinics" | "specializations";

export default function SearchPage() {
  const [query, setQuery] = useState("");
  const [activeTab, setActiveTab] = useState<Tab>("doctors");
  const { data } = useSearch(query);

  const tabs: { key: Tab; label: string; count: number }[] = [
    { key: "doctors", label: "Shifokorlar", count: data?.doctors.length || 0 },
    { key: "clinics", label: "Klinikalar", count: data?.clinics.length || 0 },
    { key: "specializations", label: "Mutaxassislik", count: data?.specializations.length || 0 },
  ];

  return (
    <div className="max-w-3xl mx-auto px-4 pt-4 space-y-4">
      <div className="relative">
        <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-text-secondary" />
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Shifokor, klinika yoki mutaxassislik..."
          className="w-full h-11 pl-10 pr-4 bg-surface border border-border rounded-2xl text-sm outline-none focus:border-primary transition-colors"
          autoFocus
        />
      </div>

      {query.length < 2 ? (
        <div className="text-center py-16 text-text-secondary">
          <Search className="w-12 h-12 mx-auto mb-3 opacity-30" />
          <p className="text-sm">Qidirish uchun kamida 2 ta harf kiriting</p>
        </div>
      ) : data ? (
        <>
          {/* Tabs */}
          <div className="flex gap-1 bg-bg rounded-2xl p-1">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex-1 py-2 text-sm font-medium rounded-xl transition-colors ${
                  activeTab === tab.key
                    ? "bg-surface text-text shadow-sm"
                    : "text-text-secondary"
                }`}
              >
                {tab.label} ({tab.count})
              </button>
            ))}
          </div>

          {/* Tab Content */}
          {activeTab === "doctors" && (
            <DoctorGrid doctors={data.doctors} />
          )}

          {activeTab === "clinics" && (
            data.clinics.length > 0 ? (
              <div className="space-y-2">
                {data.clinics.map((clinic) => (
                  <div key={clinic.id} className="bg-surface rounded-2xl border border-border p-4 flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-primary-light flex items-center justify-center flex-shrink-0">
                      <MapPin className="w-5 h-5 text-primary" />
                    </div>
                    <div>
                      <p className="font-medium text-sm">{clinic.name}</p>
                      <p className="text-xs text-text-secondary">{clinic.address}, {clinic.city}</p>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-12 text-text-secondary">
                <MapPin className="w-10 h-10 mx-auto mb-2 opacity-30" />
                <p className="text-sm">Klinika topilmadi</p>
              </div>
            )
          )}

          {activeTab === "specializations" && (
            data.specializations.length > 0 ? (
              <div className="flex flex-wrap gap-2">
                {data.specializations.map((spec) => (
                  <button
                    key={spec.id}
                    className="px-4 py-2 bg-surface border border-border rounded-2xl text-sm hover:border-primary/30 transition-colors"
                  >
                    {spec.name}
                  </button>
                ))}
              </div>
            ) : (
              <div className="text-center py-12 text-text-secondary">
                <p className="text-sm">Mutaxassislik topilmadi</p>
              </div>
            )
          )}
        </>
      ) : null}
    </div>
  );
}
