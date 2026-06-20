"use client";
import { useEffect, useRef, useState } from "react";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import { MapPin } from "lucide-react";

interface LocationPickerProps {
  center?: [number, number];
  onLocationSelect: (location: {
    latitude: string;
    longitude: string;
    formatted_address: string;
  }) => void;
}

export default function LocationPicker({
  center = [41.2995, 69.2401],
  onLocationSelect,
}: LocationPickerProps) {
  const mapRef = useRef<L.Map | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const markerRef = useRef<L.Marker | null>(null);
  const [selected, setSelected] = useState(false);

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

      const clickIcon = L.divIcon({
        html: `<div style="width:32px;height:32px;background:#E056C5;border:3px solid white;border-radius:50%;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,0.3);font-size:16px">📍</div>`,
        className: "",
        iconSize: [32, 32],
        iconAnchor: [16, 16],
      });

      const initialMarker = L.marker(center, { icon: clickIcon, draggable: true }).addTo(map);
      markerRef.current = initialMarker;
      reverseGeocode(center[0], center[1]);

      initialMarker.on("dragend", () => {
        const pos = initialMarker.getLatLng();
        reverseGeocode(pos.lat, pos.lng);
      });

      map.on("click", (e: L.LeafletMouseEvent) => {
        initialMarker.setLatLng(e.latlng);
        reverseGeocode(e.latlng.lat, e.latlng.lng);
        setSelected(true);
      });

      mapRef.current = map;
    }

    return () => {
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
  }, []);

  async function reverseGeocode(lat: number, lng: number) {
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&accept-language=uz`,
        { headers: { "Accept-Language": "uz" } }
      );
      const data = await res.json();
      const address = data?.display_name || `${lat.toFixed(6)}, ${lng.toFixed(6)}`;
      setSelected(true);
      onLocationSelect({
        latitude: lat.toFixed(6),
        longitude: lng.toFixed(6),
        formatted_address: address,
      });
    } catch {
      onLocationSelect({
        latitude: lat.toFixed(6),
        longitude: lng.toFixed(6),
        formatted_address: `${lat.toFixed(6)}, ${lng.toFixed(6)}`,
      });
    }
  }

  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium text-text">
        Klinika joylashuvi
      </label>
      <div
        ref={containerRef}
        className="w-full h-56 rounded-2xl border border-border overflow-hidden"
      />
      {selected && (
        <p className="text-xs text-text-secondary flex items-center gap-1">
          <MapPin className="w-3 h-3 text-primary" />
          Marker qo'yildi. Markerni sudrab yoki xaritani bosib o'zgartirishingiz mumkin.
        </p>
      )}
    </div>
  );
}
