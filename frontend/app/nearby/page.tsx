"use client";
import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import { useClinics } from "@/hooks/useClinics";
import { MapPin, Navigation, Star, Building2 } from "lucide-react";
import Link from "next/link";
import { Card, CardContent } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { formatRating } from "@/utils";
import type { Clinic } from "@/types";

const MapWithNoSSR = dynamic(() => import("@/components/map/ClinicMap"), {
  ssr: false,
  loading: () => (
    <div className="h-[50vh] bg-bg rounded-2xl flex items-center justify-center animate-pulse">
      <MapPin className="w-8 h-8 text-text-secondary/30" />
    </div>
  ),
});

export default function NearbyPage() {
  const [coords, setCoords] = useState<{ lat: number; lng: number } | null>(null);
  const [selectedClinic, setSelectedClinic] = useState<Clinic | null>(null);
  const defaultCoords = { lat: 41.2995, lng: 69.2401 };

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (pos) => setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
        () => setCoords(defaultCoords)
      );
    } else {
      setCoords(defaultCoords);
    }
  }, []);

  const currentCoords = coords || defaultCoords;
  const params: Record<string, string> = {
    lat: currentCoords.lat.toString(),
    lng: currentCoords.lng.toString(),
    ordering: "distance",
  };
  const { data: clinics, isLoading } = useClinics(params);

  return (
    <div className="flex flex-col h-[calc(100dvh-3.5rem)] max-w-3xl mx-auto">
      <div className="px-4 py-3 border-b border-border bg-surface">
        <h1 className="text-lg font-bold">Atrof</h1>
        <p className="text-xs text-text-secondary mt-0.5">
          {coords ? "Sizning joylashuvingiz bo'yicha klinikalar" : "Eng yaqin klinikalar"}
        </p>
      </div>

      <div className="flex-1 flex flex-col overflow-hidden">
        <div className="h-[50vh] min-h-[300px] flex-shrink-0">
          <MapWithNoSSR
            clinics={clinics || []}
            center={[currentCoords.lat, currentCoords.lng]}
            userLocation={[currentCoords.lat, currentCoords.lng]}
            onClinicSelect={setSelectedClinic}
          />
        </div>

        <div className="flex-1 overflow-y-auto px-4 py-3">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-bold flex items-center gap-1.5">
              <Building2 className="w-4 h-4 text-primary" />
              {clinics?.length || 0} ta klinika
            </h2>
          </div>

          {selectedClinic && (
            <Card className="mb-3 border-primary/30 bg-primary/[0.03]">
              <CardContent className="p-4">
                <div className="flex gap-3">
                  <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-primary-light to-secondary/10 flex-shrink-0 overflow-hidden">
                    {selectedClinic.image ? (
                      <img src={selectedClinic.image} alt={selectedClinic.name} className="w-full h-full object-cover" />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center">
                        <Building2 className="w-6 h-6 text-primary/40" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-sm">{selectedClinic.name}</h3>
                    <div className="flex items-center gap-1 mt-0.5">
                      <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                      <span className="text-xs font-medium">{formatRating(selectedClinic.avg_rating)}</span>
                      <span className="text-xs text-text-secondary">({selectedClinic.review_count})</span>
                    </div>
                    <p className="text-xs text-text-secondary mt-1 line-clamp-1">{selectedClinic.address}</p>
                    <Link href={`/clinics/${selectedClinic.id}`}>
                      <Button size="sm" className="mt-2 !py-1">Klinikani ko'rish</Button>
                    </Link>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {isLoading ? (
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="h-24 bg-gray-100 rounded-2xl animate-pulse" />
              ))}
            </div>
          ) : clinics?.length ? (
            <div className="space-y-3">
              {clinics.map((clinic) => (
                <Link key={clinic.id} href={`/clinics/${clinic.id}`}>
                  <Card className="hover:shadow-md transition-shadow">
                    <CardContent className="p-3 flex items-center gap-3">
                      <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-primary-light to-secondary/10 flex-shrink-0 overflow-hidden">
                        {clinic.image ? (
                          <img src={clinic.image} alt={clinic.name} className="w-full h-full object-cover" />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center">
                            <Building2 className="w-6 h-6 text-primary/40" />
                          </div>
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-sm">{clinic.name}</h3>
                        <div className="flex items-center gap-2 mt-0.5">
                          <div className="flex items-center gap-1">
                            <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
                            <span className="text-xs font-medium">{formatRating(clinic.avg_rating)}</span>
                          </div>
                          <span className="text-xs text-text-secondary">{clinic.doctors_count} ta shifokor</span>
                        </div>
                        <p className="text-xs text-text-secondary mt-1 line-clamp-1">{clinic.address}</p>
                      </div>
                    </CardContent>
                  </Card>
                </Link>
              ))}
            </div>
          ) : (
            <div className="text-center py-12 text-text-secondary">
              <MapPin className="w-10 h-10 mx-auto mb-2 opacity-30" />
              <p className="text-sm">Yaqin atrofda klinika topilmadi</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
