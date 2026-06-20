import api from "./api";
import type { Appointment } from "@/types";

export const appointmentService = {
  async myAppointments(): Promise<Appointment[]> {
    const res = await api.get("/appointments/");
    return res.data.results || res.data;
  },

  async create(data: {
    doctor: number;
    service?: number;
    appointment_date: string;
    appointment_time: string;
    note?: string;
  }): Promise<Appointment> {
    const res = await api.post("/appointments/create/", data);
    return res.data;
  },

  async cancel(id: number): Promise<Appointment> {
    const res = await api.patch(`/appointments/${id}/cancel/`);
    return res.data;
  },

  async confirm(id: number): Promise<Appointment> {
    const res = await api.patch(`/appointments/${id}/confirm/`);
    return res.data;
  },
};
