"use client";
import { useEffect, useRef } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import type { Clinic } from "@/types";
import { formatRating } from "@/utils";

interface ClinicMapProps {
  clinics: Clinic[];
  center: [number, number];
  userLocation: [number, number];
  onClinicSelect?: (clinic: Clinic) => void;
}

export default function ClinicMap({ clinics, center, userLocation, onClinicSelect }: ClinicMapProps) {
  const mapRef = useRef<L.Map | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (containerRef.current && !mapRef.current) {
      const map = L.map(containerRef.current, {
        center,
        zoom: 13,
        zoomControl: false,
      });

      L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution: "© OpenStreetMap",
        maxZoom: 18,
      }).addTo(map);

      L.control.zoom({ position: "bottomright" }).addTo(map);
      mapRef.current = map;
    }

    return () => {
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;
    if (center[0] !== userLocation[0] || center[1] !== userLocation[1]) {
      map.setView(center, 13);
    }
  }, [center[0], center[1]]);

  useEffect(() => {
    const map = mapRef.current;
    if (!map) return;

    const markers: L.Marker[] = [];

    const userIcon = L.divIcon({
      html: `<div style="width:20px;height:20px;background:#00B5D8;border:3px solid white;border-radius:50%;box-shadow:0 2px 6px rgba(0,0,0,0.3)"></div>`,
      className: "",
      iconSize: [20, 20],
      iconAnchor: [10, 10],
    });

    L.marker(userLocation, { icon: userIcon })
      .addTo(map)
      .bindPopup("<div style='font-size:12px;font-weight:600'>Siz</div>");

    if (Array.isArray(clinics)) {
      clinics.forEach((clinic) => {
        const icon = L.divIcon({
          html: `<div style="width:36px;height:36px;background:white;border:2px solid #00B5D8;border-radius:50%;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,0.15);font-size:16px">🏥</div>`,
          className: "",
          iconSize: [36, 36],
          iconAnchor: [18, 18],
        });

        const lat = clinic.latitude ? parseFloat(clinic.latitude) : userLocation[0];
        const lng = clinic.longitude ? parseFloat(clinic.longitude) : userLocation[1];

        if (isNaN(lat) || isNaN(lng)) return;

        const marker = L.marker([lat, lng], { icon }).addTo(map);

        const popupHtml = `
          <div style="min-width:200px;font-family:system-ui,sans-serif">
            ${clinic.image ? `<img src="${clinic.image}" alt="${clinic.name}" style="width:100%;height:100px;object-fit:cover;border-radius:8px;margin-bottom:8px" />` : ""}
            <div style="font-weight:600;font-size:14px;margin-bottom:4px">${clinic.name}</div>
            <div style="display:flex;align-items:center;gap:4px;font-size:12px;margin-bottom:4px">
              <span style="color:#f59e0b">★</span>
              <span style="font-weight:600">${formatRating(clinic.avg_rating)}</span>
              <span style="color:#999">(${clinic.review_count})</span>
            </div>
            <div style="font-size:11px;color:#666;margin-bottom:8px">📍 ${clinic.address || ""}</div>
            <a href="/clinics/${clinic.id}" style="display:block;text-align:center;background:#00B5D8;color:white;padding:6px 12px;border-radius:12px;font-size:12px;font-weight:500;text-decoration:none">
              Klinikani ko'rish
            </a>
          </div>
        `;

        marker.bindPopup(popupHtml, { closeButton: true, maxWidth: 260 });

        marker.on("click", () => {
          if (onClinicSelect) onClinicSelect(clinic);
        });

        markers.push(marker);
      });
    }

    return () => {
      markers.forEach((m) => m.remove());
    };
  }, [clinics]);

  return (
    <div
      ref={containerRef}
      className="w-full h-full rounded-0"
      style={{ zIndex: 1 }}
    />
  );
}
