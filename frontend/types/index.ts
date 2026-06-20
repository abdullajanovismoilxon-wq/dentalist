export interface User {
  id: number;
  username: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  avatar: string | null;
  role: "patient" | "doctor" | "admin";
  blood_group: string;
  allergies: string;
  date_of_birth: string | null;
  gender: string;
}

export interface Specialization {
  id: number;
  name: string;
}

export interface ClinicImage {
  id: number;
  clinic: number;
  image: string;
  uploaded_by: number;
  created_at: string;
}

export interface Clinic {
  id: number;
  name: string;
  description: string;
  address: string;
  city: string;
  phone: string;
  is_24_7: boolean;
  image: string | null;
  latitude: string | null;
  longitude: string | null;
  formatted_address: string;
  avg_rating: number;
  review_count: number;
  doctors_count: number;
  rating_breakdown: Record<string, { count: number; percentage: number }>;
  gallery: ClinicImage[];
  created_at: string;
}

export interface ClinicReview {
  id: number;
  user: number;
  user_detail: User;
  clinic: number;
  rating: number;
  comment: string;
  created_at: string;
}

export interface Doctor {
  id: number;
  full_name: string;
  image: string | null;
  gender: string;
  experience_years: number;
  specializations: Specialization[];
  clinic_name: string;
  clinic_address: string;
  clinic_latitude: string | null;
  clinic_longitude: string | null;
  consultation_price: string;
  avg_rating: number;
  review_count: number;
  is_active: boolean;
  distance_km?: number | null;
}

export interface DoctorDetail extends Doctor {
  phone: string;
  bio: string;
  clinic: Clinic;
  services: Service[];
  schedules: DoctorSchedule[];
  blocked_slots: BlockedSlot[];
  is_favorited: boolean;
  certificate_images: string[];
  rating_breakdown: Record<string, { count: number; percentage: number }>;
  created_at: string;
}

export interface Service {
  id: number;
  doctor: number;
  title: string;
  price: string;
  duration_minutes: number;
  description: string;
  is_active: boolean;
  created_at: string;
}

export interface DoctorSchedule {
  id: number;
  doctor: number;
  weekday: number;
  weekday_display: string;
  start_time: string;
  end_time: string;
  is_24_7: boolean;
  is_active: boolean;
}

export interface TimeSlot {
  id: number;
  doctor: number;
  date: string;
  start_time: string;
  status: "available" | "blocked" | "booked";
}

export interface BlockedSlot {
  id: number;
  doctor: number;
  date: string;
  start_time: string;
  end_time: string;
  reason: string;
}

export interface Appointment {
  id: number;
  patient: number;
  patient_detail: User;
  doctor: number;
  doctor_detail: Doctor;
  service: number | null;
  appointment_date: string;
  appointment_time: string;
  note: string;
  status: "pending" | "confirmed" | "completed" | "cancelled";
  created_at: string;
}

export interface Review {
  id: number;
  user: number;
  user_detail: User;
  doctor: number;
  rating: number;
  comment: string;
  created_at: string;
}

export interface Favorite {
  id: number;
  user: number;
  doctor: number;
  doctor_detail: Doctor;
  created_at: string;
}

export interface ChatRoom {
  id: number;
  patient: number;
  patient_detail: User;
  doctor: number;
  doctor_detail: Doctor;
  last_message: { text: string; sender: number; created_at: string } | null;
  unread_count: number;
  created_at: string;
  updated_at: string;
}

export interface Message {
  id: number;
  room: number;
  sender: number;
  sender_name: string;
  text: string;
  image: string | null;
  is_read: boolean;
  created_at: string;
}

export interface Notification {
  id: number;
  recipient: number;
  type: string;
  title: string;
  message: string;
  data: Record<string, unknown>;
  is_read: boolean;
  created_at: string;
}

export interface SearchResults {
  doctors: Doctor[];
  clinics: { id: number; name: string; address: string; city: string }[];
  specializations: { id: number; name: string }[];
}

export interface AuthResponse {
  user: User;
  refresh: string;
  access: string;
}

export interface PaginatedResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}
