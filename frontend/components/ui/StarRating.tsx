"use client";
import { cn } from "@/utils";

interface StarRatingProps {
  rating: number;
  onChange?: (rating: number) => void;
  size?: "sm" | "md" | "lg";
  maxStars?: number;
  disabled?: boolean;
  showValue?: boolean;
}

const sizeMap = {
  sm: "w-4 h-4",
  md: "w-5 h-5",
  lg: "w-7 h-7",
};

export function StarRating({
  rating,
  onChange,
  size = "md",
  maxStars = 5,
  disabled = false,
  showValue = false,
}: StarRatingProps) {
  return (
    <div className="flex items-center gap-0.5">
      {Array.from({ length: maxStars }, (_, i) => {
        const starValue = i + 1;
        const filled = starValue <= rating;
        return (
          <button
            key={i}
            type="button"
            disabled={disabled || !onChange}
            onClick={() => onChange?.(starValue)}
            className={cn(
              "transition-all",
              onChange && !disabled ? "cursor-pointer hover:scale-110" : "cursor-default",
              sizeMap[size],
            )}
          >
            <svg
              viewBox="0 0 24 24"
              className={cn("w-full h-full", filled ? "text-amber-400" : "text-gray-200")}
              fill={filled ? "currentColor" : "none"}
              stroke="currentColor"
              strokeWidth="1.5"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"
              />
            </svg>
          </button>
        );
      })}
      {showValue && (
        <span className="ml-1 text-sm font-semibold text-text-secondary">{rating.toFixed(1)}</span>
      )}
    </div>
  );
}
