import api from "./api";
import type { DoctorSchedule, TimeSlot } from "@/types";

export const scheduleService = {
  async getSchedules(): Promise<DoctorSchedule[]> {
    const res = await api.get("/doctors/schedule/");
    return res.data;
  },

  async createSchedule(data: {
    weekday: number;
    start_time: string;
    end_time: string;
    is_24_7?: boolean;
  }): Promise<DoctorSchedule> {
    const res = await api.post("/doctors/schedule/", data);
    return res.data;
  },

  async updateSchedule(id: number, data: Partial<DoctorSchedule>): Promise<DoctorSchedule> {
    const res = await api.patch(`/doctors/schedule/${id}/`, data);
    return res.data;
  },

  async deleteSchedule(id: number): Promise<void> {
    await api.delete(`/doctors/schedule/${id}/`);
  },

  async getTimeSlots(doctorId: number, date: string): Promise<TimeSlot[]> {
    const res = await api.get(`/schedule/slots/${doctorId}/`, { params: { date } });
    return res.data.slots;
  },

  async toggleSlotBlock(slotId: number): Promise<TimeSlot> {
    const res = await api.patch(`/schedule/slots/${slotId}/toggle-block/`);
    return res.data;
  },
};
