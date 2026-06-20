import { create } from "zustand";

interface UIState {
  activeFilter: string;
  setActiveFilter: (filter: string) => void;
}

export const useUIStore = create<UIState>((set) => ({
  activeFilter: "Barchasi",
  setActiveFilter: (filter) => set({ activeFilter: filter }),
}));
