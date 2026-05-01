"use client";

import { useEffect, useRef, useState } from "react";
import { toPng } from "html-to-image";

// ─── iPhone canvas dimensions (design at largest iPhone size) ─────────────────
const W = 1320;
const H = 2868;

// ─── iPad canvas dimensions (design at largest iPad size) ─────────────────────
const IW = 2064;
const IH = 2752;

// iPhone mockup measurements
const MK_W = 1022;
const MK_H = 2082;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// iPhone export sizes
const IPHONE_SIZES = [
  { label: '6.9"', w: 1320, h: 2868 },
  { label: '6.5"', w: 1284, h: 2778 },
  { label: '6.3"', w: 1206, h: 2622 },
  { label: '6.1"', w: 1125, h: 2436 },
] as const;

// iPad export sizes
const IPAD_SIZES = [
  { label: '13"', w: 2064, h: 2752 },
  { label: '12.9"', w: 2048, h: 2732 },
] as const;

type Device = "iphone" | "ipad";

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

// ─── iPad mockup component (CSS-only) ────────────────────────────────────────
function IPad({
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
      style={{ aspectRatio: "770/1000", ...style }}
    >
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: "5% / 3.6%",
          background: "linear-gradient(180deg, #2C2C2E 0%, #1C1C1E 100%)",
          position: "relative",
          overflow: "hidden",
          boxShadow:
            "inset 0 0 0 1px rgba(255,255,255,0.1), 0 8px 40px rgba(0,0,0,0.6)",
        }}
      >
        {/* Front camera dot */}
        <div
          style={{
            position: "absolute",
            top: "1.2%",
            left: "50%",
            transform: "translateX(-50%)",
            width: "0.9%",
            height: "0.65%",
            borderRadius: "50%",
            background: "#111113",
            border: "1px solid rgba(255,255,255,0.08)",
            zIndex: 20,
          }}
        />
        {/* Bezel edge highlight */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "5% / 3.6%",
            border: "1px solid rgba(255,255,255,0.06)",
            pointerEvents: "none",
            zIndex: 15,
          }}
        />
        {/* Screen area */}
        <div
          style={{
            position: "absolute",
            left: "4%",
            top: "2.8%",
            width: "92%",
            height: "94.4%",
            borderRadius: "2.2% / 1.6%",
            overflow: "hidden",
            background: "#000",
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

// ═══════════════════════════════════════════════════════════════════════════════
// ─── iPhone SLIDE COMPONENTS ──────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

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
      <Blob color={C.blue} size={900} style={{ top: -200, left: -200 }} />
      <Blob color={C.lime} size={600} style={{ top: 300, right: -250, opacity: 0.25 }} />
      <Blob color="#6B3AED" size={700} style={{ bottom: 400, left: -300 }} />

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
      <Blob color={C.lime} size={500} style={{ top: H * 0.1, right: -200, opacity: 0.3 }} />

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
      <Blob color={C.lime} size={600} style={{ top: -200, right: -200, opacity: 0.18 }} />
      <Blob color={C.blue} size={400} style={{ bottom: H * 0.3, right: -100, opacity: 0.12 }} />

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
        <div style={{ display: "flex", flexWrap: "wrap", gap: W * 0.025, justifyContent: "center" }}>
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

// ═══════════════════════════════════════════════════════════════════════════════
// ─── iPad SLIDE COMPONENTS ────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

/** iPad Slide 1 — Hero (DARK) */
function IPadSlide1() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(160deg, ${C.navy} 0%, ${C.navyMid} 60%, #0F1870 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <Blob color={C.blue} size={1400} style={{ top: -300, left: -300 }} />
      <Blob color={C.lime} size={900} style={{ top: 400, right: -400, opacity: 0.25 }} />
      <Blob color="#6B3AED" size={1100} style={{ bottom: 500, left: -400 }} />

      <div
        style={{
          marginTop: IW * 0.06,
          width: IW * 0.12,
          height: IW * 0.12,
          borderRadius: IW * 0.028,
          overflow: "hidden",
          boxShadow: `0 ${IW * 0.02}px ${IW * 0.05}px rgba(0,0,0,0.5)`,
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

      <div
        style={{
          marginTop: IW * 0.04,
          textAlign: "center",
          zIndex: 2,
          position: "relative",
          padding: `0 ${IW * 0.1}px`,
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
          canvasW={IW}
        />
      </div>

      <IPad
        src="/screenshots/tr/03-bekleyenler.png"
        alt="Operasyon ekranı"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(10%)",
          width: "66%",
          zIndex: 3,
          filter: "drop-shadow(0 40px 80px rgba(0,0,0,0.7))",
        }}
      />
    </div>
  );
}

/** iPad Slide 2 — Müşteri paneli (LIGHT) */
function IPadSlide2() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: C.surface,
        display: "flex",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: IH * 0.48,
          background: `linear-gradient(180deg, ${C.blue} 0%, ${C.blueLight} 70%, ${C.surface} 100%)`,
          zIndex: 0,
        }}
      />
      <Blob color={C.lime} size={800} style={{ top: IH * 0.1, right: -300, opacity: 0.3 }} />

      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: IW * 0.1,
          padding: `0 ${IW * 0.1}px`,
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
          canvasW={IW}
        />
      </div>

      <IPad
        src="/screenshots/tr/01-siparis-formu.png"
        alt="Sipariş formu"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(6%)",
          width: "68%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.25))",
        }}
      />
    </div>
  );
}

/** iPad Slide 3 — Operasyon ekranı (LIGHT, two iPads) */
function IPadSlide3() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: "#FFFFFF",
        display: "flex",
        flexDirection: "column",
      }}
    >
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
      <Blob color={C.lime} size={900} style={{ top: -300, right: -300, opacity: 0.18 }} />
      <Blob color={C.blue} size={600} style={{ bottom: IH * 0.3, right: -200, opacity: 0.12 }} />

      <div
        style={{
          position: "absolute",
          top: IW * 0.1,
          right: IW * 0.06,
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
          canvasW={IW}
        />
      </div>

      <IPad
        src="/screenshots/tr/03-bekleyenler.png"
        alt="Kurye bekleyenler"
        style={{
          position: "absolute",
          bottom: 0,
          left: "-6%",
          width: "64%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(0,0,0,0.2))",
        }}
      />
      <IPad
        src="/screenshots/tr/04-yeni-siparis.png"
        alt="Yeni sipariş"
        style={{
          position: "absolute",
          bottom: 0,
          right: "-10%",
          width: "52%",
          zIndex: 2,
          opacity: 0.6,
          transform: "rotate(4deg) translateY(10%)",
          filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
        }}
      />
    </div>
  );
}

/** iPad Slide 4 — Raporlar (DARK) */
function IPadSlide4() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(150deg, ${C.navy} 0%, #0A0F40 50%, #060B2A 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <Blob color={C.blue} size={1100} style={{ top: 300, left: -500 }} />
      <Blob color={C.lime} size={800} style={{ top: 150, right: -350, opacity: 0.2 }} />
      <Blob color="#4F1DE8" size={1200} style={{ bottom: 300, right: -500 }} />

      <div
        style={{
          marginTop: IW * 0.07,
          textAlign: "center",
          zIndex: 2,
          position: "relative",
          padding: `0 ${IW * 0.08}px`,
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
          canvasW={IW}
        />
      </div>

      <div
        style={{
          marginTop: IW * 0.045,
          zIndex: 2,
          position: "relative",
          background: "rgba(255,255,255,0.08)",
          border: `1px solid rgba(255,255,255,0.12)`,
          borderRadius: IW * 0.03,
          padding: `${IW * 0.045}px ${IW * 0.06}px`,
          display: "flex",
          gap: IW * 0.08,
          backdropFilter: "blur(20px)",
        }}
      >
        {[
          { value: "9.042", unit: "TL", label: "Bu ay" },
          { value: "26", unit: "iş", label: "Sipariş" },
          { value: "1", unit: "aktif", label: "Kurye" },
        ].map((stat) => (
          <div key={stat.label} style={{ textAlign: "center" }}>
            <div
              style={{
                fontSize: IW * 0.065,
                fontWeight: 800,
                color: C.lime,
                lineHeight: 1,
              }}
            >
              {stat.value}
              <span style={{ fontSize: IW * 0.028, color: "rgba(255,255,255,0.5)", marginLeft: 4 }}>
                {stat.unit}
              </span>
            </div>
            <div
              style={{
                fontSize: IW * 0.02,
                color: "rgba(255,255,255,0.45)",
                marginTop: IW * 0.008,
                letterSpacing: "0.08em",
              }}
            >
              {stat.label}
            </div>
          </div>
        ))}
      </div>

      <IPad
        src="/screenshots/tr/05-raporlar.png"
        alt="Raporlar"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(10%)",
          width: "66%",
          zIndex: 3,
          filter: "drop-shadow(0 40px 80px rgba(0,0,0,0.7))",
        }}
      />
    </div>
  );
}

/** iPad Slide 5 — Kurye ekranı (LIGHT) */
function IPadSlide5() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: C.surface,
        display: "flex",
        flexDirection: "column",
      }}
    >
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
      <Blob color={C.blue} size={800} style={{ top: IH * 0.05, right: -300, opacity: 0.1 }} />
      <Blob color={C.lime} size={600} style={{ bottom: IH * 0.1, left: -150, opacity: 0.3 }} />

      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: IW * 0.1,
          padding: `0 ${IW * 0.1}px`,
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
          canvasW={IW}
        />
      </div>

      <IPad
        src="/screenshots/tr/07-kurye.png"
        alt="Kurye ekranı"
        style={{
          position: "absolute",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(6%)",
          width: "68%",
          zIndex: 3,
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.2))",
        }}
      />
    </div>
  );
}

/** iPad Slide 6 — Geçmiş (LIGHT, two iPads) */
function IPadSlide6() {
  return (
    <div
      style={{
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: "#FFFFFF",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: IH * 0.42,
          background: `linear-gradient(180deg, ${C.limeDark} 0%, ${C.lime} 50%, #FFFFFF 100%)`,
          zIndex: 0,
        }}
      />
      <Blob color={C.blue} size={600} style={{ top: IH * 0.1, left: -300, opacity: 0.15 }} />

      <div
        style={{
          position: "relative",
          zIndex: 2,
          marginTop: IW * 0.1,
          padding: `0 ${IW * 0.1}px`,
          textAlign: "center",
        }}
      >
        <p
          style={{
            fontSize: IW * 0.028,
            fontWeight: 600,
            letterSpacing: "0.14em",
            textTransform: "uppercase" as const,
            color: C.textPrimary,
            marginBottom: IW * 0.018,
            lineHeight: 1,
          }}
        >
          Sipariş Geçmişi
        </p>
        <h2
          style={{
            fontSize: IW * 0.093,
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

      <IPad
        src="/screenshots/tr/02-gecmis.png"
        alt="Geçmiş siparişler"
        style={{
          position: "absolute",
          bottom: 0,
          left: "-8%",
          width: "54%",
          zIndex: 2,
          opacity: 0.6,
          transform: "rotate(-4deg) translateY(10%)",
          filter: "drop-shadow(0 20px 40px rgba(0,0,0,0.15))",
        }}
      />
      <IPad
        src="/screenshots/tr/01-siparis-formu.png"
        alt="Sipariş formu"
        style={{
          position: "absolute",
          bottom: 0,
          right: "-4%",
          width: "66%",
          zIndex: 3,
          transform: "translateY(8%)",
          filter: "drop-shadow(0 30px 60px rgba(7,33,232,0.2))",
        }}
      />
    </div>
  );
}

/** iPad Slide 7 — More features (DARK) */
function IPadSlide7() {
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
        width: IW,
        height: IH,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(160deg, ${C.navy} 0%, #0C1050 60%, #070830 100%)`,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      <Blob color={C.blue} size={1100} style={{ top: -300, right: -300 }} />
      <Blob color={C.lime} size={800} style={{ bottom: 400, left: -300, opacity: 0.2 }} />

      <div
        style={{
          marginTop: IW * 0.12,
          width: IW * 0.13,
          height: IW * 0.13,
          borderRadius: IW * 0.03,
          overflow: "hidden",
          boxShadow: `0 ${IW * 0.02}px ${IW * 0.05}px rgba(0,0,0,0.6)`,
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

      <div
        style={{
          marginTop: IW * 0.06,
          textAlign: "center",
          zIndex: 2,
          padding: `0 ${IW * 0.08}px`,
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
          canvasW={IW}
        />
      </div>

      <div
        style={{
          marginTop: IW * 0.07,
          zIndex: 2,
          padding: `0 ${IW * 0.08}px`,
          display: "flex",
          flexWrap: "wrap",
          gap: IW * 0.02,
          justifyContent: "center",
        }}
      >
        {features.map((f) => (
          <div
            key={f}
            style={{
              background: "rgba(255,255,255,0.08)",
              border: "1px solid rgba(255,255,255,0.14)",
              borderRadius: IW * 0.08,
              padding: `${IW * 0.018}px ${IW * 0.035}px`,
              fontSize: IW * 0.028,
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

      <div
        style={{
          marginTop: IW * 0.09,
          zIndex: 2,
          textAlign: "center",
          padding: `0 ${IW * 0.08}px`,
        }}
      >
        <p
          style={{
            fontSize: IW * 0.02,
            fontWeight: 600,
            letterSpacing: "0.12em",
            color: "rgba(255,255,255,0.3)",
            textTransform: "uppercase",
            marginBottom: IW * 0.035,
          }}
        >
          Yakında
        </p>
        <div style={{ display: "flex", flexWrap: "wrap", gap: IW * 0.02, justifyContent: "center" }}>
          {["Harita takibi", "Bildirimler", "İstatistikler"].map((f) => (
            <div
              key={f}
              style={{
                background: "rgba(255,255,255,0.04)",
                border: "1px solid rgba(255,255,255,0.06)",
                borderRadius: IW * 0.08,
                padding: `${IW * 0.018}px ${IW * 0.035}px`,
                fontSize: IW * 0.028,
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

// ─── Slide registries ─────────────────────────────────────────────────────────
const IPHONE_SLIDES = [
  { id: "01-hero", label: "Hero", Component: Slide1 },
  { id: "02-musteri", label: "Müşteri", Component: Slide2 },
  { id: "03-operasyon", label: "Operasyon", Component: Slide3 },
  { id: "04-raporlar", label: "Raporlar", Component: Slide4 },
  { id: "05-kurye", label: "Kurye", Component: Slide5 },
  { id: "06-gecmis", label: "Geçmiş", Component: Slide6 },
  { id: "07-more", label: "Daha Fazla", Component: Slide7 },
];

const IPAD_SLIDES = [
  { id: "01-hero", label: "Hero", Component: IPadSlide1 },
  { id: "02-musteri", label: "Müşteri", Component: IPadSlide2 },
  { id: "03-operasyon", label: "Operasyon", Component: IPadSlide3 },
  { id: "04-raporlar", label: "Raporlar", Component: IPadSlide4 },
  { id: "05-kurye", label: "Kurye", Component: IPadSlide5 },
  { id: "06-gecmis", label: "Geçmiş", Component: IPadSlide6 },
  { id: "07-more", label: "Daha Fazla", Component: IPadSlide7 },
];

// ─── Screenshot preview (scaled) ─────────────────────────────────────────────
function ScreenshotPreview({
  slide,
  exportRef,
  onExport,
  exporting,
  canvasW,
  canvasH,
}: {
  slide: { id: string; label: string; Component: React.ComponentType };
  exportRef: React.RefObject<HTMLDivElement | null>;
  onExport: () => void;
  exporting: boolean;
  canvasW: number;
  canvasH: number;
}) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(0.2);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const ro = new ResizeObserver(() => {
      const s = el.clientWidth / canvasW;
      setScale(s);
    });
    ro.observe(el);
    return () => ro.disconnect();
  }, [canvasW]);

  return (
    <div className="flex flex-col gap-2">
      <div
        ref={containerRef}
        style={{
          width: "100%",
          aspectRatio: `${canvasW}/${canvasH}`,
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
            width: canvasW,
            height: canvasH,
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

      <div
        ref={exportRef}
        style={{
          position: "absolute",
          left: -9999,
          top: 0,
          width: canvasW,
          height: canvasH,
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
  const [device, setDevice] = useState<Device>("iphone");
  const [sizeIndex, setSizeIndex] = useState(0);
  const [exportingIdx, setExportingIdx] = useState<number | null>(null);
  const [exportingAll, setExportingAll] = useState(false);
  const exportRefs = useRef<(HTMLDivElement | null)[]>([]);

  const isIpad = device === "ipad";
  const SLIDES = isIpad ? IPAD_SLIDES : IPHONE_SLIDES;
  const SIZES = isIpad ? IPAD_SIZES : IPHONE_SIZES;
  const canvasW = isIpad ? IW : W;
  const canvasH = isIpad ? IH : H;

  const size = SIZES[Math.min(sizeIndex, SIZES.length - 1)];

  async function exportSlide(idx: number, overrideSize?: { w: number; h: number }, overrideLabel?: string): Promise<void> {
    const el = exportRefs.current[idx];
    if (!el) return;

    el.style.left = "0px";
    el.style.opacity = "1";
    el.style.zIndex = "-1";

    const opts = { width: canvasW, height: canvasH, pixelRatio: 1, cacheBust: true, fontFamily: "Inter, sans-serif" };

    try {
      await toPng(el, opts);
      const dataUrl = await toPng(el, opts);

      const targetSize = overrideSize ?? size;

      const img = new Image();
      await new Promise<void>((res) => {
        img.onload = () => res();
        img.src = dataUrl;
      });

      const canvas = document.createElement("canvas");
      canvas.width = targetSize.w;
      canvas.height = targetSize.h;
      const ctx = canvas.getContext("2d")!;
      ctx.drawImage(img, 0, 0, targetSize.w, targetSize.h);

      const finalUrl = canvas.toDataURL("image/png");
      const a = document.createElement("a");
      const slideId = SLIDES[idx].id;
      const prefix = overrideLabel ? `${overrideLabel}_` : "";
      a.download = `${prefix}${slideId}-${targetSize.w}x${targetSize.h}.png`;
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

  async function handleExportFastlane() {
    const iphoneSizes = [
      { label: "iPhone6.9", w: 1320, h: 2868 },
      { label: "iPhone6.5", w: 1284, h: 2778 },
    ];
    const ipadSizes = [
      { label: "iPad13", w: 2064, h: 2752 },
      { label: "iPad12.9", w: 2048, h: 2732 },
    ];
    const fastlaneSizes = isIpad ? ipadSizes : iphoneSizes;

    setExportingAll(true);
    for (const fs of fastlaneSizes) {
      for (let i = 0; i < SLIDES.length; i++) {
        setExportingIdx(i);
        const el = exportRefs.current[i];
        if (!el) continue;
        el.style.left = "0px";
        el.style.opacity = "1";
        el.style.zIndex = "-1";
        const opts = { width: canvasW, height: canvasH, pixelRatio: 1, cacheBust: true, fontFamily: "Inter, sans-serif" };
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

        {/* Device toggle */}
        <div style={{ display: "flex", gap: 4, background: "rgba(255,255,255,0.06)", borderRadius: 8, padding: 3 }}>
          {(["iphone", "ipad"] as Device[]).map((d) => (
            <button
              key={d}
              onClick={() => { setDevice(d); setSizeIndex(0); }}
              style={{
                padding: "5px 14px",
                borderRadius: 6,
                fontSize: 12,
                fontWeight: 700,
                cursor: "pointer",
                border: "none",
                background: device === d ? C.blue : "transparent",
                color: device === d ? "#fff" : "rgba(255,255,255,0.5)",
                transition: "all 0.15s",
              }}
            >
              {d === "iphone" ? "iPhone" : "iPad"}
            </button>
          ))}
        </div>

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
            key={`${device}-${slide.id}`}
            slide={slide}
            exportRef={{ current: exportRefs.current[i] } as React.RefObject<HTMLDivElement | null>}
            onExport={() => handleExportOne(i)}
            exporting={exportingIdx === i}
            canvasW={canvasW}
            canvasH={canvasH}
          />
        ))}
      </div>

      {/* Off-screen export containers */}
      <div style={{ position: "absolute", left: -9999, top: 0 }}>
        {SLIDES.map((slide, i) => (
          <div
            key={`export-${device}-${slide.id}`}
            ref={(el) => { exportRefs.current[i] = el; }}
            style={{ width: canvasW, height: canvasH }}
          >
            <slide.Component />
          </div>
        ))}
      </div>
    </div>
  );
}
