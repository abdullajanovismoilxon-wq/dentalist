"use client";
import { Star } from "lucide-react";

interface BreakdownData {
  [key: string]: {
    count: number;
    percentage: number;
  };
}

interface StarBreakdownProps {
  breakdown: BreakdownData;
  total: number;
}

export function StarBreakdown({ breakdown, total }: StarBreakdownProps) {
  if (total === 0) {
    return <p className="text-sm text-text-secondary text-center">Hali baho yo'q</p>;
  }

  return (
    <div className="space-y-1.5">
      {[5, 4, 3, 2, 1].map((star) => {
        const data = breakdown?.[String(star)];
        const percentage = data?.percentage ?? 0;
        const count = data?.count ?? 0;
        return (
          <div key={star} className="flex items-center gap-2 text-sm">
            <div className="flex items-center gap-1 w-12">
              <span className="font-medium text-xs text-text-secondary">{star}</span>
              <Star className="w-3 h-3 text-amber-400 fill-amber-400" />
            </div>
            <div className="flex-1 h-2.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-amber-400 rounded-full transition-all"
                style={{ width: `${percentage}%` }}
              />
            </div>
            <span className="text-xs text-text-secondary w-10 text-right">{count}</span>
            <span className="text-xs text-text-secondary w-10 text-right">{percentage}%</span>
          </div>
        );
      })}
    </div>
  );
}
