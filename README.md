# SpringBoot SNS

[한국어](#한국어) | [English](#english)

---

## 한국어

# SpringBoot SNS 백엔드

Spring Boot 4.0과 Java 25를 기반으로 Claude Code를 통해 바이브 코딩을 체험해 보기 위한 SNS 서비스 백엔드 토이 프로젝트입니다. 이 프로젝트는 소셜 미디어 플랫폼에 필요한 사용자 상호작용, 미디어 관리, 타임라인 생성 등의 포괄적인 기능을 제공합니다.

### 🚀 주요 기능

- **사용자 관리**: Spring Security와 Redis를 이용한 안전한 회원가입 및 세션 기반 인증.
- **게시글 시스템**:
  - 게시글 생성, 수정, 삭제.
  - 다양한 게시글 유형 지원: **일반 게시글**, **답글(Reply)**, **인용(Quote)**, **재게시(Repost)**.
  - 사용자별 게시글 목록 조회 (페이징 지원).
- **소셜 상호작용**:
  - 팔로우/언팔로우 시스템 및 팔로워/팔로잉 수 집계.
  - 게시글 좋아요/좋아요 취소 기능.
- **타임라인 및 피드**: 팔로우 중인 사용자의 게시글을 볼 수 있는 효율적인 타임라인 생성.
- **미디어 관리**:
  - S3 호환 스토리지(MinIO/RustFS) 연동.
  - Pre-signed URL 및 멀티파트 업로드를 이용한 대용량 파일 업로드 지원.
- **조회수 관리**: 게시글 조회수 추적 및 주기적 동기화.

### 🛠 기술 스택

- **언어**: Java 25
- **프레임워크**: Spring Boot 4.0.2
- **빌드 도구**: Gradle (Kotlin DSL)
- **데이터베이스**:
  - **관계형**: PostgreSQL 17 (주 저장소)
  - **인메모리**: Redis 7 (세션 관리 및 캐싱)
- **보안**: Spring Security, Spring Session Redis
- **지속성**: Spring Data JPA (Hibernate)
- **스토리지**: AWS S3 SDK (MinIO/RustFS 호환)
- **코드 품질**: Spotless (Java, Kotlin, JSON, YAML 자동 포맷팅)

### 🏗 인프라 구성

로컬 개발 환경 설정을 위해 `docker-compose.yml`이 포함되어 있습니다:

- **PostgreSQL**: 포트 `5433`
- **Redis**: 포트 `6380`
- **MinIO (RustFS)**: 포트 `9000` (API) / `9001` (콘솔)

### 🚦 시작하기

#### 사전 요구 사항

- JDK 25
- Docker 및 Docker Compose

#### 설정 방법

1. **저장소 클론**
2. **인프라 실행**:
   ```bash
   docker-compose up -d
   ```
3. **애플리케이션 빌드 및 실행**:
   ```bash
   ./gradlew bootRun
   ```

### 📖 API 문서

프로젝트의 API 엔드포인트는 도메인별로 그룹화되어 있습니다:

- `/api/v1/user`: 사용자 프로필 및 회원가입.
- `/api/v1/posts`: 게시글 CRUD 및 목록.
- `/api/v1/follows`: 팔로우 시스템.
- `/api/v1/likes`: 게시글 좋아요 상호작용.
- `/api/v1/media`: 미디어 업로드 초기화 및 상태 추적.
- `/api/v1/timeline`: 사용자 피드.

상세한 API 테스트를 위한 쉘 스크립트는 `src/main/resources/http/` 경로에서 확인할 수 있습니다.

### 🧹 코드 스타일

일관된 코드 포맷 유지를 위해 **Spotless**를 사용합니다. 코드를 정렬하려면 다음 명령어를 실행하세요:

```bash
./gradlew spotlessApply
```

---

## English

# SpringBoot SNS Backend

A SNS service backend toy project built with Spring Boot 4.0 and Java 25 to experience 'Vibe Coding' with Claude Code. This project provides a comprehensive set of features for social media platforms, including user interactions, media management, and timeline generation.

### 🚀 Features

- **User Management**: Secure signup and session-based authentication using Spring Security and Redis.
- **Post System**:
  - Create, update, and delete posts.
  - Support for multiple post types: **Original Posts**, **Replies**, **Quotes**, and **Reposts**.
  - Paginated post retrieval by user.
- **Social Interactions**:
  - Follow/Unfollow system with follower/following counts.
  - Like/Unlike functionality for posts.
- **Timeline & Feed**: Efficient timeline generation for users to see posts from their following list.
- **Media Management**:
  - S3-compatible storage integration (MinIO/RustFS).
  - Support for large file uploads using presigned URLs and multi-part uploads.
- **Post Views**: Tracking and synchronization of post view counts.

### 🛠 Tech Stack

- **Language**: Java 25
- **Framework**: Spring Boot 4.0.2
- **Build Tool**: Gradle (Kotlin DSL)
- **Database**:
  - **Relational**: PostgreSQL 17 (Primary storage)
  - **In-Memory**: Redis 7 (Session management & Caching)
- **Security**: Spring Security, Spring Session Redis
- **Persistence**: Spring Data JPA (Hibernate)
- **Storage**: AWS S3 SDK (Compatible with MinIO/RustFS)
- **Code Quality**: Spotless (Auto-formatting for Java, Kotlin, JSON, YAML)

### 🏗 Infrastructure

The project includes a `docker-compose.yml` for easy local development setup:

- **PostgreSQL**: Port `5433`
- **Redis**: Port `6380`
- **MinIO (RustFS)**: Port `9000` (API) / `9001` (Console)

### 🚦 Getting Started

#### Prerequisites

- JDK 25
- Docker & Docker Compose

#### Setup

1. **Clone the repository**
2. **Start Infrastructure**:
   ```bash
   docker-compose up -d
   ```
3. **Build and Run**:
   ```bash
   ./gradlew bootRun
   ```

### 📖 API Documentation

The project includes various API endpoints grouped by domain:

- `/api/v1/user`: User profile and signup.
- `/api/v1/posts`: Post CRUD and listing.
- `/api/v1/follows`: Following system.
- `/api/v1/likes`: Post like interactions.
- `/api/v1/media`: Media upload initialization and status tracking.
- `/api/v1/timeline`: User feed.

Detailed shell scripts for testing APIs can be found in `src/main/resources/http/`.

### 🧹 Code Style

We use **Spotless** to maintain consistent code formatting. To format the code, run:

```bash
./gradlew spotlessApply
```
