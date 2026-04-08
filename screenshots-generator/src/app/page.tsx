"use client";

import { useEffect, useRef, useState } from "react";
import { toPng } from "html-to-image";

// ─── Canvas dimensions (design at largest iPhone size) ───────────────────────
const W = 1320;
const H = 2868;

// iPhone mockup measurements
const MK_W = 1022;
const MK_H = 2082;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// Export sizes
const SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
  { label: '6.1"', w: 1125, h: 2436 },
] as const;

// ─── Brand colors ─────────────────────────────────────────────────────────────
const C = {
  blue: "#0721E8",
  blueDark: "#0519B8",
  blueLight: "#3A4FED",
  lime: "#C9ED11",
  limeDark: "#B5D40E",
  white: "#FFFFFF",
  surface: "#F8FAFC",
  surfaceMid: "#F1F5F9",
  border: "#E2E8F0",
  textMuted: "#64748B",
  textPrimary: "#0F172A",
  navy: "#06082A",
  navyMid: "#0B1240",
};

// ─── Phone mockup component ───────────────────────────────────────────────────
function Phone({
  src,
  alt,
  style,
  className = "",
}: {
  src: string;
  alt: string;
  style?: React.CSSProperties;
  className?: string;
}) {
  return (
    <div
      className={`relative ${className}`}
      style={{ aspectRatio: `${MK_W}/${MK_H}`, ...style }}
    >
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img
        src="/mockup.png"
        alt=""
        style={{ display: "block", width: "100%", height: "100%" }}
        draggable={false}
      />
      <div
        className="absolute z-10 overflow-hidden"
        style={{
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src={src}
          alt={alt}
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
          }}
          draggable={false}
        />
      </div>
    </div>
  );
}

// ─── Caption component ────────────────────────────────────────────────────────
function Caption({
  label,
  headline,
  dark,
  align = "center",
  canvasW = W,
}: {
  label: string;
  headline: React.ReactNode;
  dark?: boolean;
  align?: "left" | "center" | "right";
  canvasW?: number;
}) {
  const ratio = canvasW / W;
  return (
    <div style={{ textAlign: align }}>
      <p
        style={{
          fontSize: canvasW * 0.028,
          fontWeight: 600,
          letterSpacing: "0.14em",
          textTransform: "uppercase",
          color: dark ? C.lime : C.blue,
          marginBottom: canvasW * 0.018,
          lineHeight: 1,
        }}
      >
        {label}
      </p>
      <h2
        style={{
          fontSize: canvasW * 0.093,
          fontWeight: 800,
          lineHeight: 1.0,
          color: dark ? C.white : C.textPrimary,
          margin: 0,
        }}
      >
        {headline}
      </h2>
    </div>
  );
}

// ─── Decorative blobs ─────────────────────────────────────────────────────────
function Blob({
  color,
  size,
  style,
}: {
  color: string;
  size: number;
  style: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "absolute",
        width: size,
        height: size,
        borderRadius: "50%",
        background: color,
        filter: "blur(120px)",
        opacity: 0.55,
        ...style,
      }}
    />
  );
}

// ─── SLIDE COMPONENTS ─────────────────────────────────────────────────────────

/** Slide 1 — Hero (DARK) */
function Slide1() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(160deg, ${C.navy} 0%, ${C.navyMid} 60%, #0F1870 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      {/* Blobs */}
      <Blob color={C.blue} size={900} style={{ top: -200, left: -200 }} />
      <Blob color={C.lime} size={600} style={{ top: 300, right: -250, opacity: 0.25 }} />
      <Blob color="#6B3AED" size={700} style={{ bottom: 400, left: -300 }} />

      {/* App icon */}
      <div
        style={{
          marginTop: W * 0.09,
          width: W * 0.17,
          height: W * 0.17,
          borderRadius: W * 0.04,
          overflow: "hidden",
          boxShadow: `0 ${W * 0.03}px ${W * 0.06}px rgba(0,0,0,0.5)`,
          flexShrink: 0,
          zIndex: 2,
          position: "relative",
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src="/app-icon.png"
          alt="Kuryem"
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
          draggable={false}
        />
      </div>

      {/* Caption */}
      <div
        style={{
          marginTop: W * 0.055,
          textAlign: "center",
          zIndex: 2,
          position: "relative",
          padding: `0 ${W * 0.08}px`,
        }}
      >
        <Caption
          label="Kuryem"
          headline={
            <>
              Kurye yönetimi,
              <br />
              artık kolaylaştı.
            </>
          }
          dark
          align="center"
        />
      </div>

      {/* Phone — centered, bottom */}
      <Phone
        src="/screenshots/tr/03-bekleyenler.png"
        alt="Operasyon ekranı"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(10%)",
          width: "80%",
          zIndex: 3,
          filter: "drop-shadow(0 40px 80px rgba(0,0,0,0.7))",
        }}
      />
    </div>
  );
}

/** Slide 2 — Müşteri paneli (LIGHT) */
function Slide2() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: C.surface,
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Top blue accent bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: H * 0.48,
          background: `linear-gradient(180deg, ${C.blue} 0%, ${C.blueLight} 70%, ${C.surface} 100%)`,
          zIndex: 0,
        }}
      />

      {/* Blob accent */}
      <Blob color={C.lime} size={500} style={{ top: H * 0.1, right: -200, opacity: 0.3 }} />

      {/* Caption */}
      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: W * 0.14,
          padding: `0 ${W * 0.1}px`,
          textAlign: "center",
        }}
      >
        <Caption
          label="Müşteri Paneli"
          headline={
            <>
              Kurye çağır,
              <br />
              bir dokunuşla.
            </>
          }
          dark
          align="center"
        />
      </div>

      {/* Phone — centered, bottom */}
      <Phone
        src="/screenshots/tr/01-siparis-formu.png"
        alt="Sipariş formu"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(6%)",
          width: "82%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.25))",
        }}
      />
    </div>
  );
}

/** Slide 3 — Operasyon ekranı (LIGHT) */
function Slide3() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: "#FFFFFF",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Left blue stripe */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "40%",
          height: "100%",
          background: `linear-gradient(180deg, ${C.blueLight} 0%, ${C.blue} 100%)`,
          zIndex: 0,
        }}
      />

      {/* Lime accent blob top-right */}
      <Blob color={C.lime} size={600} style={{ top: -200, right: -200, opacity: 0.18 }} />
      <Blob color={C.blue} size={400} style={{ bottom: H * 0.3, right: -100, opacity: 0.12 }} />

      {/* Caption — right side */}
      <div
        style={{
          position: "absolute",
          top: W * 0.15,
          right: W * 0.08,
          width: "52%",
          zIndex: 2,
          textAlign: "right",
        }}
      >
        <Caption
          label="Operasyon"
          headline={
            <>
              Tüm emirler,
              <br />
              tek ekranda.
            </>
          }
          align="right"
        />
      </div>

      {/* Phone — left-offset, bottom */}
      <Phone
        src="/screenshots/tr/03-bekleyenler.png"
        alt="Kurye bekleyenler"
        style={{
          position: "absolute",
          bottom: 0,
          left: "-6%",
          width: "78%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(0,0,0,0.2))",
        }}
      />

      {/* Second phone — right, back */}
      <Phone
        src="/screenshots/tr/04-yeni-siparis.png"
        alt="Yeni sipariş"
        style={{
          position: "absolute",
          bottom: 0,
          right: "-10%",
          width: "62%",
          zIndex: 2,
          opacity: 0.6,
          transform: "rotate(4deg) translateY(10%)",
          filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
        }}
      />
    </div>
  );
}

/** Slide 4 — Raporlar (DARK) */
function Slide4() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(150deg, ${C.navy} 0%, #0A0F40 50%, #060B2A 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <Blob color={C.blue} size={700} style={{ top: 200, left: -300 }} />
      <Blob color={C.lime} size={500} style={{ top: 100, right: -200, opacity: 0.2 }} />
      <Blob color="#4F1DE8" size={800} style={{ bottom: 200, right: -300 }} />

      {/* Caption */}
      <div
        style={{
          marginTop: W * 0.09,
          textAlign: "center",
          zIndex: 2,
          position: "relative",
          padding: `0 ${W * 0.08}px`,
        }}
      >
        <Caption
          label="Raporlar"
          headline={
            <>
              Cironu anlık
              <br />
              takip et.
            </>
          }
          dark
          align="center"
        />
      </div>

      {/* Stats pill */}
      <div
        style={{
          marginTop: W * 0.06,
          zIndex: 2,
          position: "relative",
          background: "rgba(255,255,255,0.08)",
          border: `1px solid rgba(255,255,255,0.12)`,
          borderRadius: W * 0.04,
          padding: `${W * 0.06}px ${W * 0.08}px`,
          display: "flex",
          gap: W * 0.1,
          backdropFilter: "blur(20px)",
        }}
      >
        {[
          { value: "9.042", unit: "TL", label: "Bu ay" },
          { value: "26", unit: "iş", label: "Kurye" },
          { value: "1", unit: "aktif", label: "Kurye" },
        ].map((stat) => (
          <div key={stat.label} style={{ textAlign: "center" }}>
            <div
              style={{
                fontSize: W * 0.065,
                fontWeight: 800,
                color: C.lime,
                lineHeight: 1,
              }}
            >
              {stat.value}
              <span style={{ fontSize: W * 0.03, color: "rgba(255,255,255,0.5)", marginLeft: 4 }}>
                {stat.unit}
              </span>
            </div>
            <div
              style={{
                fontSize: W * 0.022,
                color: "rgba(255,255,255,0.45)",
                marginTop: W * 0.01,
                letterSpacing: "0.08em",
              }}
            >
              {stat.label}
            </div>
          </div>
        ))}
      </div>

      {/* Phone */}
      <Phone
        src="/screenshots/tr/05-raporlar.png"
        alt="Raporlar"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(10%)",
          width: "80%",
          zIndex: 3,
          filter: "drop-shadow(0 40px 80px rgba(0,0,0,0.7))",
        }}
      />
    </div>
  );
}

/** Slide 5 — Kurye ekranı (LIGHT) */
function Slide5() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: C.surface,
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Bottom wave accent */}
      <div
        style={{
          position: "absolute",
          bottom: 0,
          left: 0,
          right: 0,
          height: "55%",
          background: `linear-gradient(0deg, ${C.blue}22 0%, transparent 100%)`,
          zIndex: 0,
        }}
      />
      <Blob color={C.blue} size={500} style={{ top: H * 0.05, right: -200, opacity: 0.1 }} />
      <Blob color={C.lime} size={400} style={{ bottom: H * 0.1, left: -100, opacity: 0.3 }} />

      {/* Caption */}
      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: W * 0.15,
          padding: `0 ${W * 0.1}px`,
          textAlign: "center",
        }}
      >
        <Caption
          label="Kurye Ekranı"
          headline={
            <>
              İş geldi,
              <br />
              hemen haberdar ol.
            </>
          }
          align="center"
        />
      </div>

      {/* Phone */}
      <Phone
        src="/screenshots/tr/07-kurye.png"
        alt="Kurye ekranı"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(6%)",
          width: "82%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.2))",
        }}
      />
    </div>
  );
}

/** Slide 6 — Geçmiş / Sipariş takibi (LIGHT, two phones) */
function Slide6() {
  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: "#FFFFFF",
        display: "flex",
        flexDirection: "column",
      }}
    >
      {/* Lime top accent */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: H * 0.42,
          background: `linear-gradient(180deg, ${C.limeDark} 0%, ${C.lime} 50%, #FFFFFF 100%)`,
          zIndex: 0,
        }}
      />
      <Blob color={C.blue} size={400} style={{ top: H * 0.1, left: -200, opacity: 0.15 }} />

      {/* Caption */}
      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: W * 0.14,
          padding: `0 ${W * 0.1}px`,
          textAlign: "center",
        }}
      >
        <p
          style={{
            fontSize: W * 0.028,
            fontWeight: 600,
            letterSpacing: "0.14em",
            textTransform: "uppercase" as const,
            color: C.textPrimary,
            marginBottom: W * 0.018,
            lineHeight: 1,
          }}
        >
          Sipariş Geçmişi
        </p>
        <h2
          style={{
            fontSize: W * 0.093,
            fontWeight: 800,
            lineHeight: 1.0,
            color: C.textPrimary,
            margin: 0,
          }}
        >
          Her teslimat,
          <br />
          kayıt altında.
        </h2>
      </div>

      {/* Two phones */}
      <Phone
        src="/screenshots/tr/02-gecmis.png"
        alt="Geçmiş siparişler"
        style={{
          position: "absolute",
          bottom: 0,
          left: "-8%",
          width: "65%",
          zIndex: 2,
          opacity: 0.6,
          transform: "rotate(-4deg) translateY(10%)",
          filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
        }}
      />
      <Phone
        src="/screenshots/tr/01-siparis-formu.png"
        alt="Sipariş formu"
        style={{
          position: "absolute",
          bottom: 0,
          right: "-4%",
          width: "80%",
          zIndex: 3,
          transform: "translateY(8%)",
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.2))",
        }}
      />
    </div>
  );
}

/** Slide 7 — More features (DARK) */
function Slide7() {
  const features = [
    "Müşteri yönetimi",
    "Personel hesapları",
    "Kurye atama",
    "Uğrama talepleri",
    "Ciro analizi",
    "Gerçek zamanlı takip",
    "Rol tabanlı erişim",
    "Çoklu durak",
    "Sipariş geçmişi",
  ];

  return (
    <div
      style={{
        width: W,
        height: H,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(160deg, ${C.navy} 0%, #0C1050 60%, #070830 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <Blob color={C.blue} size={700} style={{ top: -200, right: -200 }} />
      <Blob color={C.lime} size={500} style={{ bottom: 300, left: -200, opacity: 0.2 }} />

      {/* App icon */}
      <div
        style={{
          marginTop: W * 0.18,
          width: W * 0.18,
          height: W * 0.18,
          borderRadius: W * 0.04,
          overflow: "hidden",
          boxShadow: `0 ${W * 0.03}px ${W * 0.06}px rgba(0,0,0,0.6)`,
          zIndex: 2,
          flexShrink: 0,
        }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          src="/app-icon.png"
          alt="Kuryem"
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
          draggable={false}
        />
      </div>

      {/* Caption */}
      <div
        style={{
          marginTop: W * 0.08,
          textAlign: "center",
          zIndex: 2,
          padding: `0 ${W * 0.08}px`,
        }}
      >
        <Caption
          label="Kuryem"
          headline={
            <>
              Ve çok daha
              <br />
              fazlası.
            </>
          }
          dark
          align="center"
        />
      </div>

      {/* Feature pills */}
      <div
        style={{
          marginTop: W * 0.1,
          zIndex: 2,
          padding: `0 ${W * 0.08}px`,
          display: "flex",
          flexWrap: "wrap",
          gap: W * 0.025,
          justifyContent: "center",
        }}
      >
        {features.map((f) => (
          <div
            key={f}
            style={{
              background: "rgba(255,255,255,0.08)",
              border: "1px solid rgba(255,255,255,0.14)",
              borderRadius: W * 0.1,
              padding: `${W * 0.022}px ${W * 0.042}px`,
              fontSize: W * 0.032,
              fontWeight: 600,
              color: "rgba(255,255,255,0.85)",
              letterSpacing: "0.02em",
              backdropFilter: "blur(10px)",
            }}
          >
            {f}
          </div>
        ))}
      </div>

      {/* Divider + coming soon */}
      <div
        style={{
          marginTop: W * 0.12,
          zIndex: 2,
          textAlign: "center",
          padding: `0 ${W * 0.08}px`,
        }}
      >
        <p
          style={{
            fontSize: W * 0.024,
            fontWeight: 600,
            letterSpacing: "0.12em",
            color: "rgba(255,255,255,0.3)",
            textTransform: "uppercase",
            marginBottom: W * 0.04,
          }}
        >
          Yakında
        </p>
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            gap: W * 0.025,
            justifyContent: "center",
          }}
        >
          {["Harita takibi", "Bildirimler", "İstatistikler"].map((f) => (
            <div
              key={f}
              style={{
                background: "rgba(255,255,255,0.04)",
                border: "1px solid rgba(255,255,255,0.06)",
                borderRadius: W * 0.1,
                padding: `${W * 0.022}px ${W * 0.042}px`,
                fontSize: W * 0.032,
                fontWeight: 600,
                color: "rgba(255,255,255,0.3)",
              }}
            >
              {f}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── Slide registry ───────────────────────────────────────────────────────────
const SLIDES = [
  { id: "01-hero", label: "Hero", Component: Slide1 },
  { id: "02-musteri", label: "Müşteri", Component: Slide2 },
  { id: "03-operasyon", label: "Operasyon", Component: Slide3 },
  { id: "04-raporlar", label: "Raporlar", Component: Slide4 },
  { id: "05-kurye", label: "Kurye", Component: Slide5 },
  { id: "06-gecmis", label: "Geçmiş", Component: Slide6 },
  { id: "07-more", label: "Daha Fazla", Component: Slide7 },
];

// ─── Screenshot preview (scaled) ─────────────────────────────────────────────
function ScreenshotPreview({
  slide,
  exportRef,
  onExport,
  exporting,
}: {
  slide: (typeof SLIDES)[number];
  exportRef: React.RefObject<HTMLDivElement | null>;
  onExport: () => void;
  exporting: boolean;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(0.2);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const ro = new ResizeObserver(() => {
      const s = el.clientWidth / W;
      setScale(s);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  return (
    <div className="flex flex-col gap-2">
      {/* Preview container */}
      <div
        ref={containerRef}
        style={{
          width: "100%",
          height: `${(H / W) * 100}%`,
          aspectRatio: `${W}/${H}`,
          position: "relative",
          overflow: "hidden",
          borderRadius: 8,
          cursor: "pointer",
          boxShadow: "0 4px 20px rgba(0,0,0,0.15)",
        }}
        onClick={onExport}
        title="Click to export"
      >
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            transformOrigin: "top left",
            transform: `scale(${scale})`,
            width: W,
            height: H,
          }}
        >
          <slide.Component />
        </div>
        {exporting && (
          <div
            style={{
              position: "absolute",
              inset: 0,
              background: "rgba(0,0,0,0.5)",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#fff",
              fontSize: 12,
              fontWeight: 600,
            }}
          >
            Exporting…
          </div>
        )}
      </div>
      <p style={{ fontSize: 11, textAlign: "center", color: "#64748B", fontWeight: 600 }}>
        {slide.label}
      </p>

      {/* Offscreen export element */}
      <div
        ref={exportRef}
        style={{
          position: "absolute",
          left: -9999,
          top: 0,
          width: W,
          height: H,
          zIndex: -1,
        }}
      >
        <slide.Component />
      </div>
    </div>
  );
}

// ─── Main page ────────────────────────────────────────────────────────────────
export default function ScreenshotsPage() {
  const [sizeIndex, setSizeIndex] = useState(0);
  const [exportingIdx, setExportingIdx] = useState<number | null>(null);
  const [exportingAll, setExportingAll] = useState(false);
  const exportRefs = useRef<(HTMLDivElement | null)[]>([]);

  const size = SIZES[sizeIndex];

  async function exportSlide(idx: number, prefix?: string): Promise<void> {
    const el = exportRefs.current[idx];
    if (!el) return;

    // Move on-screen temporarily
    el.style.left = "0px";
    el.style.opacity = "1";
    el.style.zIndex = "-1";

    const opts = { width: W, height: H, pixelRatio: 1, cacheBust: true, fontFamily: "Inter, sans-serif" };

    try {
      await toPng(el, opts); // warm-up call
      const dataUrl = await toPng(el, opts);

      // Scale to target size
      const img = new Image();
      await new Promise<void>((res) => {
        img.onload = () => res();
        img.src = dataUrl;
      });

      const canvas = document.createElement("canvas");
      canvas.width = size.w;
      canvas.height = size.h;
      const ctx = canvas.getContext("2d")!;
      ctx.drawImage(img, 0, 0, size.w, size.h);

      const finalUrl = canvas.toDataURL("image/png");
      const a = document.createElement("a");
      const slideId = SLIDES[idx].id;
      a.download = `${prefix || ""}${slideId}-${size.w}x${size.h}.png`;
      a.href = finalUrl;
      a.click();
    } finally {
      el.style.left = "-9999px";
      el.style.opacity = "";
      el.style.zIndex = "";
    }
  }

  async function handleExportOne(idx: number) {
    setExportingIdx(idx);
    await exportSlide(idx);
    setExportingIdx(null);
  }

  async function handleExportAll() {
    setExportingAll(true);
    for (let i = 0; i < SLIDES.length; i++) {
      setExportingIdx(i);
      await exportSlide(i);
      await new Promise((r) => setTimeout(r, 300));
    }
    setExportingIdx(null);
    setExportingAll(false);
  }

  // Fastlane: export all slides at 6.9" and 6.5" with proper naming
  async function handleExportFastlane() {
    const fastlaneSizes = [
      { label: "iPhone6.9", w: 1320, h: 2868 },
      { label: "iPhone6.5", w: 1284, h: 2778 },
    ];
    setExportingAll(true);
    for (const fs of fastlaneSizes) {
      for (let i = 0; i < SLIDES.length; i++) {
        setExportingIdx(i);
        const el = exportRefs.current[i];
        if (!el) continue;
        el.style.left = "0px";
        el.style.opacity = "1";
        el.style.zIndex = "-1";
        const opts = { width: W, height: H, pixelRatio: 1, cacheBust: true, fontFamily: "Inter, sans-serif" };
        try {
          await toPng(el, opts);
          const dataUrl = await toPng(el, opts);
          const img = new Image();
          await new Promise<void>((res) => { img.onload = () => res(); img.src = dataUrl; });
          const canvas = document.createElement("canvas");
          canvas.width = fs.w; canvas.height = fs.h;
          canvas.getContext("2d")!.drawImage(img, 0, 0, fs.w, fs.h);
          const a = document.createElement("a");
          a.download = `fastlane_${fs.label}_${SLIDES[i].id}.png`;
          a.href = canvas.toDataURL("image/png");
          a.click();
        } finally {
          el.style.left = "-9999px"; el.style.opacity = ""; el.style.zIndex = "";
        }
        await new Promise((r) => setTimeout(r, 300));
      }
    }
    setExportingIdx(null);
    setExportingAll(false);
  }

  return (
    <div style={{ minHeight: "100vh", background: "#0F172A", fontFamily: "Inter, sans-serif" }}>
      {/* Toolbar */}
      <div
        style={{
          position: "sticky",
          top: 0,
          zIndex: 100,
          background: "#1E293B",
          borderBottom: "1px solid rgba(255,255,255,0.08)",
          padding: "12px 24px",
          display: "flex",
          alignItems: "center",
          gap: 16,
          flexWrap: "wrap",
        }}
      >
        <span style={{ color: "#F8FAFC", fontWeight: 800, fontSize: 15, letterSpacing: "-0.02em" }}>
          Kuryem Screenshots
        </span>

        {/* Size selector */}
        <div style={{ display: "flex", gap: 6 }}>
          {SIZES.map((s, i) => (
            <button
              key={s.label}
              onClick={() => setSizeIndex(i)}
              style={{
                padding: "5px 12px",
                borderRadius: 6,
                fontSize: 12,
                fontWeight: 600,
                cursor: "pointer",
                border: "none",
                background: sizeIndex === i ? C.blue : "rgba(255,255,255,0.08)",
                color: sizeIndex === i ? "#fff" : "rgba(255,255,255,0.6)",
              }}
            >
              {s.label} ({s.w}×{s.h})
            </button>
          ))}
        </div>

        {/* Export all */}
        <button
          onClick={handleExportAll}
          disabled={exportingAll}
          style={{
            marginLeft: "auto",
            padding: "7px 18px",
            borderRadius: 8,
            fontSize: 13,
            fontWeight: 700,
            cursor: exportingAll ? "not-allowed" : "pointer",
            border: "none",
            background: exportingAll ? "#334155" : C.lime,
            color: exportingAll ? "#94A3B8" : C.textPrimary,
          }}
        >
          {exportingAll ? "Dışa aktarılıyor…" : "Tümünü İndir"}
        </button>

        {/* Fastlane export */}
        <button
          onClick={handleExportFastlane}
          disabled={exportingAll}
          style={{
            padding: "7px 18px",
            borderRadius: 8,
            fontSize: 13,
            fontWeight: 700,
            cursor: exportingAll ? "not-allowed" : "pointer",
            border: `1px solid ${C.blue}`,
            background: exportingAll ? "#334155" : "transparent",
            color: exportingAll ? "#94A3B8" : C.blue,
          }}
        >
          {exportingAll ? "…" : "🚀 Fastlane İndir"}
        </button>
      </div>

      {/* Grid */}
      <div
        style={{
          padding: "32px 24px",
          display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
          gap: 24,
          maxWidth: 1800,
          margin: "0 auto",
        }}
      >
        {SLIDES.map((slide, i) => (
          <ScreenshotPreview
            key={slide.id}
            slide={slide}
            exportRef={{ current: exportRefs.current[i] } as React.RefObject<HTMLDivElement | null>}
            onExport={() => handleExportOne(i)}
            exporting={exportingIdx === i}
          />
        ))}
      </div>

      {/* Off-screen export containers — one per slide */}
      <div style={{ position: "absolute", left: -9999, top: 0 }}>
        {SLIDES.map((slide, i) => (
          <div
            key={slide.id}
            ref={(el) => { exportRefs.current[i] = el; }}
            style={{ width: W, height: H }}
          >
            <slide.Component />
          </div>
        ))}
      </div>
    </div>
  );
}
