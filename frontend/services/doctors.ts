import api from "./api";
import type { Doctor, DoctorDetail, TimeSlot } from "@/types";

export const doctorService = {
  async list(params?: Record<string, string>): Promise<Doctor[]> {
    const res = await api.get("/doctors/", { params });
    return res.data.results || res.data;
  },

  async nearby(params: Record<string, string>): Promise<Doctor[]> {
    const res = await api.get("/doctors/nearby/", { params });
    return res.data.results || res.data;
  },

  async getById(id: number): Promise<DoctorDetail> {
    const res = await api.get(`/doctors/${id}/`);
    return res.data;
  },

  async getAvailableTimes(doctorId: number, date: string): Promise<TimeSlot[]> {
    const res = await api.get(`/schedule/slots/${doctorId}/`, {
      params: { date },
    });
    return res.data.slots;
  },
};
