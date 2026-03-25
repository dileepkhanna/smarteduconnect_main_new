-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Mar 24, 2026 at 07:37 AM
-- Server version: 11.8.3-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u923569146_smarteduco`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `target_audience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_audience`)),
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `content`, `target_audience`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'test announce', 'announcement', '[\"class:1-A\"]', 2, '2026-03-21 10:54:56', '2026-03-21 10:54:56'),
(2, 'checkl', 'check', '[\"all\"]', 1, '2026-03-21 10:57:55', '2026-03-21 10:57:55');

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(255) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `setting_key`, `setting_value`, `updated_by`, `created_at`, `updated_at`) VALUES
(1, 'receipt_template', '{\"schoolName\":\"\",\"schoolAddress\":\"\",\"schoolPhone\":\"\",\"headerTitle\":\"FEE RECEIPT\",\"footerText\":\"This is a computer-generated receipt.\",\"showAdmissionNumber\":true,\"showClass\":true,\"showDiscount\":true,\"showLogo\":true,\"logoUrl\":\"https:\\/\\/schoolwebapp1.s3.ap-south-2.amazonaws.com\\/receipt-logos\\/3azpcg0gIJCXB8r8iuDxE40oP9mVIkHccibjanqy.png\"}', 1, NULL, '2026-03-21 09:47:31'),
(2, 'leads_module_enabled', '0', 1, NULL, '2026-03-21 10:15:29');

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `date` date NOT NULL,
  `status` varchar(255) NOT NULL,
  `session` varchar(255) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `marked_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`id`, `student_id`, `date`, `status`, `session`, `reason`, `marked_by`, `created_at`, `updated_at`) VALUES
(1, 1, '2026-03-21', 'present', NULL, NULL, 1, '2026-03-21 07:54:31', '2026-03-21 07:54:31');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `certificate_requests`
--

CREATE TABLE `certificate_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `certificate_type` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `requested_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `admin_remarks` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `section` varchar(255) NOT NULL,
  `class_teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `academic_year` varchar(255) NOT NULL DEFAULT '2026-2027',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`id`, `name`, `section`, `class_teacher_id`, `academic_year`, `created_at`, `updated_at`) VALUES
(1, '1', 'A', 1, '2026-2027', '2026-03-21 07:53:26', '2026-03-21 07:53:26');

-- --------------------------------------------------------

--
-- Table structure for table `complaints`
--

CREATE TABLE `complaints` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `submitted_by` bigint(20) UNSIGNED NOT NULL,
  `visible_to` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`visible_to`)),
  `response` text DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'open',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exams`
--

CREATE TABLE `exams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `class_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exam_date` date DEFAULT NULL,
  `exam_time` time DEFAULT NULL,
  `max_marks` int(11) NOT NULL DEFAULT 100,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_cycles`
--

CREATE TABLE `exam_cycles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_type` varchar(30) NOT NULL,
  `cycle_number` int(10) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_marks`
--

CREATE TABLE `exam_marks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `marks_obtained` decimal(8,2) DEFAULT NULL,
  `grade` varchar(20) DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fees`
--

CREATE TABLE `fees` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `fee_type` varchar(255) NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `due_date` date NOT NULL,
  `payment_status` varchar(20) NOT NULL DEFAULT 'unpaid',
  `reminder_days_before` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `paid_at` timestamp NULL DEFAULT NULL,
  `receipt_number` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_payments`
--

CREATE TABLE `fee_payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `fee_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) NOT NULL DEFAULT 'cash',
  `receipt_number` varchar(255) DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `recorded_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fee_payment_orders`
--

CREATE TABLE `fee_payment_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `fee_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `parent_user_id` bigint(20) UNSIGNED NOT NULL,
  `razorpay_order_id` varchar(255) NOT NULL,
  `razorpay_payment_id` varchar(255) DEFAULT NULL,
  `razorpay_signature` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'INR',
  `status` varchar(20) NOT NULL DEFAULT 'created',
  `order_payload` text DEFAULT NULL,
  `verification_payload` text DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `gallery_folders`
--

CREATE TABLE `gallery_folders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gallery_folders`
--

INSERT INTO `gallery_folders` (`id`, `title`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'photos', 1, '2026-03-21 08:32:14', '2026-03-21 08:32:14');

-- --------------------------------------------------------

--
-- Table structure for table `gallery_images`
--

CREATE TABLE `gallery_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `folder_id` bigint(20) UNSIGNED NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `caption` varchar(255) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gallery_images`
--

INSERT INTO `gallery_images` (`id`, `folder_id`, `image_url`, `caption`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/gallery/1/657d4dee-1ea6-4270-8ce2-3dd3f5ca36d7.jpeg', 'WhatsApp Image 2026-03-21 at 2.48.49 PM', 1, '2026-03-21 09:45:35', '2026-03-21 09:45:35');

-- --------------------------------------------------------

--
-- Table structure for table `homework`
--

CREATE TABLE `homework` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` date NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leads`
--

CREATE TABLE `leads` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_name` varchar(255) NOT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `current_class` varchar(255) DEFAULT NULL,
  `class_applying_for` varchar(255) DEFAULT NULL,
  `academic_year` varchar(255) DEFAULT NULL,
  `father_name` varchar(255) DEFAULT NULL,
  `mother_name` varchar(255) DEFAULT NULL,
  `primary_contact_person` varchar(255) DEFAULT NULL,
  `primary_mobile` varchar(255) DEFAULT NULL,
  `alternate_mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `area_city` varchar(255) DEFAULT NULL,
  `father_education` varchar(255) DEFAULT NULL,
  `mother_education` varchar(255) DEFAULT NULL,
  `father_occupation` varchar(255) DEFAULT NULL,
  `mother_occupation` varchar(255) DEFAULT NULL,
  `annual_income_range` varchar(255) DEFAULT NULL,
  `previous_school` varchar(255) DEFAULT NULL,
  `education_board` varchar(255) DEFAULT NULL,
  `medium_of_instruction` varchar(255) DEFAULT NULL,
  `last_class_passed` varchar(255) DEFAULT NULL,
  `academic_performance` text DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'new_lead',
  `next_followup_date` date DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `assigned_teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lead_call_logs`
--

CREATE TABLE `lead_call_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `lead_id` bigint(20) UNSIGNED NOT NULL,
  `called_by` bigint(20) UNSIGNED DEFAULT NULL,
  `call_outcome` varchar(50) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lead_status_history`
--

CREATE TABLE `lead_status_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `lead_id` bigint(20) UNSIGNED NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_requests`
--

CREATE TABLE `leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `request_type` varchar(255) NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `reason` text NOT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `leave_requests`
--

INSERT INTO `leave_requests` (`id`, `request_type`, `student_id`, `teacher_id`, `from_date`, `to_date`, `reason`, `attachment_url`, `status`, `approved_by`, `created_at`, `updated_at`) VALUES
(1, 'teacher', NULL, 1, '2026-03-22', '2026-03-22', 'hi', 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/leave-docs/zMb9VMs6VdgETey4Fkq1O0fpcSC7dkA1gV21wiPP.webp', 'pending', NULL, '2026-03-21 09:49:25', '2026-03-21 09:49:25');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `recipient_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `content` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `attachment_url` varchar(255) DEFAULT NULL,
  `attachment_type` varchar(30) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `recipient_id`, `student_id`, `content`, `is_read`, `attachment_url`, `attachment_type`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 1, '📷 Image', 0, 'https://darksalmon-peafowl-607492.hostingersite.com/uploads/message-attachments/1/61a9yYxIQHrW6yqrhiUvtGBOirCbqS0gDDbQrWQj.jpg', 'image', '2026-03-21 07:54:58', '2026-03-21 07:54:58'),
(2, 1, 3, 1, 'hi', 0, NULL, NULL, '2026-03-21 08:36:01', '2026-03-21 08:36:01'),
(3, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/message-attachments/1/KncNRg3Rhe3egNTnvZTjTwW6a8qtizB9Uq59HPW9.jpg', 'image', '2026-03-21 08:49:53', '2026-03-21 08:49:53'),
(4, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/message-attachments/1/U4zf11YXODOxBPQc7lApLJIUeWMzssjBEdlOTKtw.jpg', 'image', '2026-03-21 08:51:21', '2026-03-21 08:51:21'),
(5, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 08:57:37', '2026-03-21 08:57:37'),
(6, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 08:59:41', '2026-03-21 08:59:41'),
(7, 1, 2, NULL, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 09:00:55', '2026-03-21 09:00:55'),
(8, 1, 3, 1, '📎 Document', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'document', '2026-03-21 09:07:35', '2026-03-21 09:07:35'),
(9, 2, 1, NULL, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 09:11:37', '2026-03-21 09:11:37'),
(10, 2, 1, NULL, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 09:12:53', '2026-03-21 09:12:53'),
(11, 2, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/', 'image', '2026-03-21 09:16:31', '2026-03-21 09:16:31'),
(12, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/message-attachments/1/3R0AkW1XnucJnSUaJAKsRoNwbwxhLsTjfKgijlfR.jpg', 'image', '2026-03-21 09:28:49', '2026-03-21 09:28:49'),
(13, 1, 3, 1, '📷 Image', 0, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/message-attachments/1/SUvnFUSn8hnYEGp3rtDcsO4gD1wEEIlGwhaIQIah.webp', 'image', '2026-03-21 09:29:42', '2026-03-21 09:29:42');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_03_10_220000_create_school_core_tables', 1),
(5, '2026_03_10_231000_add_category_to_subjects_table', 1),
(6, '2026_03_11_120000_create_messages_table', 1),
(7, '2026_03_11_123000_create_timetable_table', 1),
(8, '2026_03_11_130000_create_settings_and_lead_permission_tables', 1),
(9, '2026_03_11_133000_create_leads_tables', 1),
(10, '2026_03_11_140000_create_exams_tables', 1),
(11, '2026_03_11_141000_create_question_papers_tables', 1),
(12, '2026_03_11_143000_create_syllabus_tables', 1),
(13, '2026_03_11_150000_add_visible_to_to_complaints_table', 1),
(14, '2026_03_11_160000_add_certificate_request_fields', 1),
(15, '2026_03_11_170000_create_gallery_tables', 1),
(16, '2026_03_11_180000_create_push_subscriptions_table', 1),
(17, '2026_03_12_120000_create_fees_tables', 1),
(18, '2026_03_12_123000_create_fee_payment_orders_table', 1),
(19, '2026_03_12_140000_enhance_notifications_schema', 1),
(20, '2026_03_12_150000_create_homework_and_student_reports_tables', 1),
(21, '2026_03_13_160000_harden_push_subscriptions_for_multi_device_support', 1);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'general',
  `entity_type` varchar(255) DEFAULT NULL,
  `entity_id` varchar(255) DEFAULT NULL,
  `priority` varchar(20) NOT NULL DEFAULT 'normal',
  `channel` varchar(20) NOT NULL DEFAULT 'both',
  `dedupe_key` varchar(255) DEFAULT NULL,
  `meta_json` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `entity_type`, `entity_id`, `priority`, `channel`, `dedupe_key`, `meta_json`, `link`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 1, 'New teacher leave request', 'A teacher submitted leave from 2026-03-22 to 2026-03-22', 'leave', 'leave_request', '1', 'high', 'both', NULL, NULL, '/admin/leave', 1, '2026-03-21 09:49:25', '2026-03-21 09:49:46'),
(2, 1, 'New announcement', 'test announce', 'announcement', 'announcement', '1', 'normal', 'both', NULL, NULL, '/admin/announcements', 1, '2026-03-21 10:54:56', '2026-03-21 10:57:02'),
(3, 2, 'New announcement', 'test announce', 'announcement', 'announcement', '1', 'normal', 'both', NULL, NULL, '/teacher/announcements', 0, '2026-03-21 10:54:56', '2026-03-21 10:54:56'),
(4, 3, 'New announcement', 'test announce', 'announcement', 'announcement', '1', 'normal', 'both', NULL, NULL, '/parent/announcements', 1, '2026-03-21 10:54:56', '2026-03-21 10:55:22'),
(5, 1, 'New announcement', 'checkl', 'announcement', 'announcement', '2', 'normal', 'both', NULL, NULL, '/admin/announcements', 1, '2026-03-21 10:57:55', '2026-03-21 11:49:27'),
(6, 2, 'New announcement', 'checkl', 'announcement', 'announcement', '2', 'normal', 'both', NULL, NULL, '/teacher/announcements', 0, '2026-03-21 10:57:55', '2026-03-21 10:57:55'),
(7, 3, 'New announcement', 'checkl', 'announcement', 'announcement', '2', 'normal', 'both', NULL, NULL, '/parent/announcements', 0, '2026-03-21 10:57:55', '2026-03-21 10:57:55');

-- --------------------------------------------------------

--
-- Table structure for table `notification_preferences`
--

CREATE TABLE `notification_preferences` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `enable_push` tinyint(1) NOT NULL DEFAULT 1,
  `enable_in_app` tinyint(1) NOT NULL DEFAULT 1,
  `critical_only_push` tinyint(1) NOT NULL DEFAULT 0,
  `category_preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`category_preferences`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parents`
--

CREATE TABLE `parents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `parents`
--

INSERT INTO `parents` (`id`, `user_id`, `phone`, `created_at`, `updated_at`) VALUES
(1, 3, '9876543217', '2026-03-21 07:54:24', '2026-03-21 07:54:24');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `profiles`
--

CREATE TABLE `profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `profiles`
--

INSERT INTO `profiles` (`id`, `user_id`, `full_name`, `email`, `phone`, `photo_url`, `created_at`, `updated_at`) VALUES
(1, 1, 'admin', 'admin@school.com', NULL, 'https://schoolwebapp1.s3.ap-south-2.amazonaws.com/avatars/di2sVG5fyZa96eGwCSMO7l5MAeSHjhXUamwkXc9G.jpg', '2026-03-21 07:52:06', '2026-03-21 09:50:52'),
(2, 2, 'dileep', 'dileep.1774079580@school.internal', '9876543218', NULL, '2026-03-21 07:53:00', '2026-03-21 07:53:00'),
(3, 3, 'sree', 'vikas-1-a@parent.local', '9876543217', NULL, '2026-03-21 07:54:24', '2026-03-21 07:54:24');

-- --------------------------------------------------------

--
-- Table structure for table `push_subscriptions`
--

CREATE TABLE `push_subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `endpoint` text NOT NULL,
  `endpoint_hash` char(64) DEFAULT NULL,
  `p256dh` text NOT NULL,
  `auth` text NOT NULL,
  `user_agent` varchar(1000) DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `push_subscriptions`
--

INSERT INTO `push_subscriptions` (`id`, `user_id`, `endpoint`, `endpoint_hash`, `p256dh`, `auth`, `user_agent`, `last_seen_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'https://fcm.googleapis.com/wp/fKWMyRS0xhA:APA91bF8lOrtcHsJ_6dF-Ynybd2BQHYw-IjmODcxUsCLXW9A_pjbxf6rWVrvUewdM6YbUCRrNzUjaGaDNivtx45Z5B-AjU3N5vojHS74N4xmkzqCKWIvwaxTz3By4qaJegeGR5Cv2TFC', '16896ed77ada090673629ea2706e00471f3e080bddc873cdfd1ce941d97c9634', 'BI4P6Ue8ShrxHvD4IUmcOry8RADs5BzQ6I2mqTQORB3Z6Li6f4_BxCL-Gk0oan-U-1DPHFELnQdIw_FmbcgGSU0', '2zwDfb_LiycyalyjrUuYyg', NULL, '2026-03-23 04:24:17', '2026-03-21 10:57:44', '2026-03-23 04:24:17');

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `question_paper_id` bigint(20) UNSIGNED NOT NULL,
  `question_number` int(10) UNSIGNED NOT NULL,
  `question_text` text NOT NULL,
  `question_type` varchar(30) NOT NULL DEFAULT 'short',
  `option_a` text DEFAULT NULL,
  `option_b` text DEFAULT NULL,
  `option_c` text DEFAULT NULL,
  `option_d` text DEFAULT NULL,
  `correct_answer` text DEFAULT NULL,
  `explanation` text DEFAULT NULL,
  `marks` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `question_papers`
--

CREATE TABLE `question_papers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `total_questions` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `total_marks` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `uploaded_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `settings_audit_log`
--

CREATE TABLE `settings_audit_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(255) NOT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings_audit_log`
--

INSERT INTO `settings_audit_log` (`id`, `setting_key`, `old_value`, `new_value`, `changed_by`, `created_at`, `updated_at`) VALUES
(1, 'leads_module_enabled', NULL, '1', 1, '2026-03-21 10:15:22', '2026-03-21 10:15:22'),
(2, 'leads_module_enabled', '1', '0', 1, '2026-03-21 10:15:29', '2026-03-21 10:15:29');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `admission_number` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `class_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `blood_group` varchar(255) DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `parent_name` varchar(255) DEFAULT NULL,
  `parent_phone` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `emergency_contact` varchar(255) DEFAULT NULL,
  `emergency_contact_name` varchar(255) DEFAULT NULL,
  `login_id` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `admission_number`, `full_name`, `class_id`, `user_id`, `date_of_birth`, `blood_group`, `photo_url`, `parent_name`, `parent_phone`, `address`, `emergency_contact`, `emergency_contact_name`, `login_id`, `password_hash`, `status`, `created_at`, `updated_at`) VALUES
(1, 'VIKAS-1-A', 'vikas', 1, NULL, '2003-08-06', 'O+', NULL, 'sree', '9876543217', NULL, NULL, NULL, 'VIKAS-1-A', '$2y$12$bgG8obfXWxAweR0uPWjWDesQ7tlogJ4fH.qX5AHnRVEmDRXgY3q0O', 'active', '2026-03-21 07:54:24', '2026-03-21 07:54:24');

-- --------------------------------------------------------

--
-- Table structure for table `student_exam_results`
--

CREATE TABLE `student_exam_results` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `obtained_marks` decimal(8,2) NOT NULL DEFAULT 0.00,
  `total_marks` decimal(8,2) DEFAULT NULL,
  `percentage` decimal(8,2) NOT NULL DEFAULT 0.00,
  `rank` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_parents`
--

CREATE TABLE `student_parents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `parent_id` bigint(20) UNSIGNED NOT NULL,
  `relationship` varchar(255) NOT NULL DEFAULT 'parent',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student_parents`
--

INSERT INTO `student_parents` (`id`, `student_id`, `parent_id`, `relationship`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'parent', '2026-03-21 07:54:24', '2026-03-21 07:54:24');

-- --------------------------------------------------------

--
-- Table structure for table `student_reports`
--

CREATE TABLE `student_reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `severity` varchar(30) NOT NULL DEFAULT 'info',
  `parent_visible` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`id`, `name`, `code`, `category`, `created_at`, `updated_at`) VALUES
(1, 'science', NULL, 'general', '2026-03-21 10:52:07', '2026-03-21 10:52:07');

-- --------------------------------------------------------

--
-- Table structure for table `syllabus`
--

CREATE TABLE `syllabus` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `syllabus_type` varchar(30) NOT NULL DEFAULT 'general',
  `exam_type` varchar(255) DEFAULT NULL,
  `chapter_name` varchar(255) DEFAULT NULL,
  `topic_name` varchar(255) NOT NULL,
  `week_number` int(10) UNSIGNED DEFAULT NULL,
  `schedule_date` date DEFAULT NULL,
  `schedule_time` time DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` varchar(255) NOT NULL,
  `subjects` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`subjects`)),
  `qualification` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `joining_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`id`, `user_id`, `teacher_id`, `subjects`, `qualification`, `status`, `joining_date`, `created_at`, `updated_at`) VALUES
(1, 2, 'DILEEP-SCIENCE', '[\"science\"]', 'bsc', 'active', '2026-03-21', '2026-03-21 07:53:00', '2026-03-21 07:53:00');

-- --------------------------------------------------------

--
-- Table structure for table `teacher_classes`
--

CREATE TABLE `teacher_classes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_lead_permissions`
--

CREATE TABLE `teacher_lead_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `teacher_syllabus_map`
--

CREATE TABLE `teacher_syllabus_map` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `teacher_id` bigint(20) UNSIGNED NOT NULL,
  `syllabus_id` bigint(20) UNSIGNED NOT NULL,
  `role_type` varchar(30) NOT NULL DEFAULT 'lead',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `timetable`
--

CREATE TABLE `timetable` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `teacher_id` bigint(20) UNSIGNED DEFAULT NULL,
  `day_of_week` varchar(20) NOT NULL,
  `period_number` int(10) UNSIGNED NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `timetable`
--

INSERT INTO `timetable` (`id`, `class_id`, `subject_id`, `teacher_id`, `day_of_week`, `period_number`, `start_time`, `end_time`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 'Monday', 1, '08:00:00', '08:45:00', 1, '2026-03-21 10:52:18', '2026-03-21 11:04:55'),
(2, 1, 1, 1, 'Tuesday', 2, '08:45:00', '09:30:00', 1, '2026-03-21 10:52:33', '2026-03-21 10:52:34'),
(3, 1, 1, 1, 'Wednesday', 3, '09:45:00', '10:30:00', 1, '2026-03-21 10:52:41', '2026-03-21 10:52:43'),
(4, 1, 1, 1, 'Thursday', 4, '10:30:00', '11:15:00', 1, '2026-03-21 10:52:50', '2026-03-21 10:52:51'),
(5, 1, 1, 1, 'Friday', 5, '11:30:00', '12:15:00', 1, '2026-03-21 10:52:59', '2026-03-21 10:53:00'),
(6, 1, 1, 1, 'Saturday', 6, '12:15:00', '13:00:00', 1, '2026-03-21 10:53:08', '2026-03-21 10:53:50'),
(7, 1, 1, 1, 'Monday', 7, '14:00:00', '14:45:00', 1, '2026-03-21 10:53:15', '2026-03-21 10:53:51'),
(8, 1, 1, 1, 'Tuesday', 8, '14:45:00', '15:30:00', 1, '2026-03-21 10:53:23', '2026-03-21 10:53:52');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `api_token` varchar(80) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `api_token`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'admin@school.com', NULL, '$2y$12$UGXKxwGOghKuXBJNO.lsNOrknTiSDtChWb0QLxKNnq1ZTBVFQC5rG', NULL, 'fdc8d3200572bf11630c2743fec10ec9f40fea9426359563021b50a82117a71d', '2026-03-21 07:52:06', '2026-03-21 10:56:28'),
(2, 'dileep', 'dileep.1774079580@school.internal', NULL, '$2y$12$VmE/aajG20VfzrwJk65ibueYS/9L6KVVPmC5EQci9.rq0L3aAyNHm', NULL, NULL, '2026-03-21 07:53:00', '2026-03-21 10:55:03'),
(3, 'sree', 'vikas-1-a@parent.local', NULL, '$2y$12$6otC9ThEpAdt9JRW4JPH0uyzcYjC7TyfwTom2llzSLYwsS1YQCqo6', NULL, NULL, '2026-03-21 07:54:24', '2026-03-21 10:56:15');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('admin','teacher','parent') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`id`, `user_id`, `role`, `created_at`, `updated_at`) VALUES
(1, 1, 'admin', '2026-03-21 07:52:06', '2026-03-21 07:52:06'),
(2, 2, 'teacher', '2026-03-21 07:53:00', '2026-03-21 07:53:00'),
(3, 3, 'parent', '2026-03-21 07:54:24', '2026-03-21 07:54:24');

-- --------------------------------------------------------

--
-- Table structure for table `weekly_exams`
--

CREATE TABLE `weekly_exams` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `class_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED DEFAULT NULL,
  `syllabus_type` varchar(30) NOT NULL DEFAULT 'general',
  `cycle_id` bigint(20) UNSIGNED DEFAULT NULL,
  `week_number` int(10) UNSIGNED DEFAULT NULL,
  `exam_title` varchar(255) NOT NULL,
  `exam_date` date NOT NULL,
  `exam_time` time NOT NULL,
  `duration_minutes` int(10) UNSIGNED NOT NULL DEFAULT 60,
  `total_marks` int(10) UNSIGNED NOT NULL DEFAULT 100,
  `negative_marking` tinyint(1) NOT NULL DEFAULT 0,
  `negative_marks_value` decimal(8,2) NOT NULL DEFAULT 0.00,
  `reminder_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(30) NOT NULL DEFAULT 'scheduled',
  `description` text DEFAULT NULL,
  `exam_type_label` varchar(255) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `weekly_exam_syllabus`
--

CREATE TABLE `weekly_exam_syllabus` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `syllabus_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `announcements_created_by_foreign` (`created_by`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `app_settings_setting_key_unique` (`setting_key`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `attendance_student_id_date_session_unique` (`student_id`,`date`,`session`),
  ADD KEY `attendance_marked_by_foreign` (`marked_by`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `certificate_requests`
--
ALTER TABLE `certificate_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `certificate_requests_student_id_foreign` (`student_id`),
  ADD KEY `certificate_requests_requested_by_foreign` (`requested_by`),
  ADD KEY `certificate_requests_approved_by_foreign` (`approved_by`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `classes_name_section_academic_year_unique` (`name`,`section`,`academic_year`),
  ADD KEY `classes_class_teacher_id_foreign` (`class_teacher_id`);

--
-- Indexes for table `complaints`
--
ALTER TABLE `complaints`
  ADD PRIMARY KEY (`id`),
  ADD KEY `complaints_submitted_by_foreign` (`submitted_by`);

--
-- Indexes for table `exams`
--
ALTER TABLE `exams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `exams_class_id_index` (`class_id`),
  ADD KEY `exams_subject_id_index` (`subject_id`),
  ADD KEY `exams_exam_date_index` (`exam_date`);

--
-- Indexes for table `exam_cycles`
--
ALTER TABLE `exam_cycles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `exam_cycles_exam_type_is_active_index` (`exam_type`,`is_active`);

--
-- Indexes for table `exam_marks`
--
ALTER TABLE `exam_marks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `exam_marks_exam_id_student_id_unique` (`exam_id`,`student_id`),
  ADD KEY `exam_marks_student_id_index` (`student_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `fees`
--
ALTER TABLE `fees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fees_student_id_due_date_index` (`student_id`,`due_date`),
  ADD KEY `fees_payment_status_index` (`payment_status`);

--
-- Indexes for table `fee_payments`
--
ALTER TABLE `fee_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fee_payments_student_id_paid_at_index` (`student_id`,`paid_at`),
  ADD KEY `fee_payments_fee_id_index` (`fee_id`);

--
-- Indexes for table `fee_payment_orders`
--
ALTER TABLE `fee_payment_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fee_payment_orders_razorpay_order_id_unique` (`razorpay_order_id`),
  ADD KEY `fee_payment_orders_fee_id_parent_user_id_index` (`fee_id`,`parent_user_id`),
  ADD KEY `fee_payment_orders_student_id_created_at_index` (`student_id`,`created_at`),
  ADD KEY `fee_payment_orders_status_index` (`status`);

--
-- Indexes for table `gallery_folders`
--
ALTER TABLE `gallery_folders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `gallery_folders_created_at_index` (`created_at`);

--
-- Indexes for table `gallery_images`
--
ALTER TABLE `gallery_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `gallery_images_folder_id_index` (`folder_id`),
  ADD KEY `gallery_images_created_at_index` (`created_at`);

--
-- Indexes for table `homework`
--
ALTER TABLE `homework`
  ADD PRIMARY KEY (`id`),
  ADD KEY `homework_class_id_due_date_index` (`class_id`,`due_date`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `leads`
--
ALTER TABLE `leads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `leads_status_index` (`status`),
  ADD KEY `leads_primary_mobile_index` (`primary_mobile`),
  ADD KEY `leads_class_applying_for_index` (`class_applying_for`),
  ADD KEY `leads_created_by_index` (`created_by`),
  ADD KEY `leads_assigned_teacher_id_index` (`assigned_teacher_id`),
  ADD KEY `leads_next_followup_date_index` (`next_followup_date`);

--
-- Indexes for table `lead_call_logs`
--
ALTER TABLE `lead_call_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lead_call_logs_lead_id_index` (`lead_id`);

--
-- Indexes for table `lead_status_history`
--
ALTER TABLE `lead_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `lead_status_history_lead_id_index` (`lead_id`),
  ADD KEY `lead_status_history_new_status_index` (`new_status`);

--
-- Indexes for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `leave_requests_student_id_foreign` (`student_id`),
  ADD KEY `leave_requests_teacher_id_foreign` (`teacher_id`),
  ADD KEY `leave_requests_approved_by_foreign` (`approved_by`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `messages_sender_id_recipient_id_index` (`sender_id`,`recipient_id`),
  ADD KEY `messages_recipient_id_is_read_index` (`recipient_id`,`is_read`),
  ADD KEY `messages_student_id_index` (`student_id`),
  ADD KEY `messages_created_at_index` (`created_at`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_created_at` (`user_id`,`created_at`),
  ADD KEY `idx_notifications_user_read` (`user_id`,`is_read`),
  ADD KEY `idx_notifications_user_type` (`user_id`,`type`),
  ADD KEY `idx_notifications_user_dedupe` (`user_id`,`dedupe_key`);

--
-- Indexes for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `notification_preferences_user_id_unique` (`user_id`),
  ADD KEY `notification_preferences_enable_push_index` (`enable_push`);

--
-- Indexes for table `parents`
--
ALTER TABLE `parents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `parents_user_id_unique` (`user_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `profiles`
--
ALTER TABLE `profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `profiles_user_id_unique` (`user_id`);

--
-- Indexes for table `push_subscriptions`
--
ALTER TABLE `push_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `push_subscriptions_endpoint_hash_unique` (`endpoint_hash`),
  ADD KEY `push_subscriptions_user_id_index` (`user_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `questions_question_paper_id_question_number_unique` (`question_paper_id`,`question_number`),
  ADD KEY `questions_question_paper_id_index` (`question_paper_id`);

--
-- Indexes for table `question_papers`
--
ALTER TABLE `question_papers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_papers_exam_id_index` (`exam_id`),
  ADD KEY `question_papers_class_id_index` (`class_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings_audit_log`
--
ALTER TABLE `settings_audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `settings_audit_log_setting_key_created_at_index` (`setting_key`,`created_at`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `students_admission_number_unique` (`admission_number`),
  ADD UNIQUE KEY `students_user_id_unique` (`user_id`),
  ADD KEY `students_class_id_foreign` (`class_id`);

--
-- Indexes for table `student_exam_results`
--
ALTER TABLE `student_exam_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_exam_results_exam_id_student_id_unique` (`exam_id`,`student_id`),
  ADD KEY `student_exam_results_student_id_index` (`student_id`);

--
-- Indexes for table `student_parents`
--
ALTER TABLE `student_parents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_parents_student_id_parent_id_unique` (`student_id`,`parent_id`),
  ADD KEY `student_parents_parent_id_foreign` (`parent_id`);

--
-- Indexes for table `student_reports`
--
ALTER TABLE `student_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_reports_student_id_created_at_index` (`student_id`,`created_at`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `syllabus`
--
ALTER TABLE `syllabus`
  ADD PRIMARY KEY (`id`),
  ADD KEY `syllabus_class_id_index` (`class_id`),
  ADD KEY `syllabus_subject_id_index` (`subject_id`),
  ADD KEY `syllabus_syllabus_type_index` (`syllabus_type`),
  ADD KEY `syllabus_exam_type_index` (`exam_type`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `teachers_teacher_id_unique` (`teacher_id`),
  ADD UNIQUE KEY `teachers_user_id_unique` (`user_id`);

--
-- Indexes for table `teacher_classes`
--
ALTER TABLE `teacher_classes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `teacher_classes_teacher_id_class_id_unique` (`teacher_id`,`class_id`),
  ADD KEY `teacher_classes_class_id_foreign` (`class_id`);

--
-- Indexes for table `teacher_lead_permissions`
--
ALTER TABLE `teacher_lead_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `teacher_lead_permissions_teacher_id_unique` (`teacher_id`),
  ADD KEY `teacher_lead_permissions_enabled_index` (`enabled`);

--
-- Indexes for table `teacher_syllabus_map`
--
ALTER TABLE `teacher_syllabus_map`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `teacher_syllabus_unique` (`teacher_id`,`syllabus_id`,`role_type`),
  ADD KEY `teacher_syllabus_map_syllabus_id_index` (`syllabus_id`);

--
-- Indexes for table `timetable`
--
ALTER TABLE `timetable`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `timetable_class_day_period_unique` (`class_id`,`day_of_week`,`period_number`),
  ADD KEY `timetable_teacher_id_is_published_index` (`teacher_id`,`is_published`),
  ADD KEY `timetable_class_id_is_published_index` (`class_id`,`is_published`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD UNIQUE KEY `users_api_token_unique` (`api_token`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_roles_user_id_unique` (`user_id`);

--
-- Indexes for table `weekly_exams`
--
ALTER TABLE `weekly_exams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `weekly_exams_class_id_index` (`class_id`),
  ADD KEY `weekly_exams_subject_id_index` (`subject_id`),
  ADD KEY `weekly_exams_exam_date_index` (`exam_date`),
  ADD KEY `weekly_exams_status_index` (`status`);

--
-- Indexes for table `weekly_exam_syllabus`
--
ALTER TABLE `weekly_exam_syllabus`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `weekly_exam_syllabus_exam_id_syllabus_id_unique` (`exam_id`,`syllabus_id`),
  ADD KEY `weekly_exam_syllabus_syllabus_id_index` (`syllabus_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `certificate_requests`
--
ALTER TABLE `certificate_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `classes`
--
ALTER TABLE `classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `complaints`
--
ALTER TABLE `complaints`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exams`
--
ALTER TABLE `exams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_cycles`
--
ALTER TABLE `exam_cycles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `exam_marks`
--
ALTER TABLE `exam_marks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fees`
--
ALTER TABLE `fees`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_payments`
--
ALTER TABLE `fee_payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `fee_payment_orders`
--
ALTER TABLE `fee_payment_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `gallery_folders`
--
ALTER TABLE `gallery_folders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `gallery_images`
--
ALTER TABLE `gallery_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `homework`
--
ALTER TABLE `homework`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leads`
--
ALTER TABLE `leads`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lead_call_logs`
--
ALTER TABLE `lead_call_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lead_status_history`
--
ALTER TABLE `lead_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `parents`
--
ALTER TABLE `parents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `profiles`
--
ALTER TABLE `profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `push_subscriptions`
--
ALTER TABLE `push_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `question_papers`
--
ALTER TABLE `question_papers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `settings_audit_log`
--
ALTER TABLE `settings_audit_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `student_exam_results`
--
ALTER TABLE `student_exam_results`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `student_parents`
--
ALTER TABLE `student_parents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `student_reports`
--
ALTER TABLE `student_reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `syllabus`
--
ALTER TABLE `syllabus`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teachers`
--
ALTER TABLE `teachers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `teacher_classes`
--
ALTER TABLE `teacher_classes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teacher_lead_permissions`
--
ALTER TABLE `teacher_lead_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `teacher_syllabus_map`
--
ALTER TABLE `teacher_syllabus_map`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `timetable`
--
ALTER TABLE `timetable`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `weekly_exams`
--
ALTER TABLE `weekly_exams`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `weekly_exam_syllabus`
--
ALTER TABLE `weekly_exam_syllabus`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_created_by_foreign` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_marked_by_foreign` FOREIGN KEY (`marked_by`) REFERENCES `teachers` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `attendance_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `certificate_requests`
--
ALTER TABLE `certificate_requests`
  ADD CONSTRAINT `certificate_requests_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `certificate_requests_requested_by_foreign` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `certificate_requests_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `classes_class_teacher_id_foreign` FOREIGN KEY (`class_teacher_id`) REFERENCES `teachers` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `complaints`
--
ALTER TABLE `complaints`
  ADD CONSTRAINT `complaints_submitted_by_foreign` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fees`
--
ALTER TABLE `fees`
  ADD CONSTRAINT `fees_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `fee_payments`
--
ALTER TABLE `fee_payments`
  ADD CONSTRAINT `fee_payments_fee_id_foreign` FOREIGN KEY (`fee_id`) REFERENCES `fees` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fee_payments_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD CONSTRAINT `leave_requests_approved_by_foreign` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `leave_requests_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `leave_requests_teacher_id_foreign` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `parents`
--
ALTER TABLE `parents`
  ADD CONSTRAINT `parents_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `profiles`
--
ALTER TABLE `profiles`
  ADD CONSTRAINT `profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_class_id_foreign` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `students_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `student_parents`
--
ALTER TABLE `student_parents`
  ADD CONSTRAINT `student_parents_parent_id_foreign` FOREIGN KEY (`parent_id`) REFERENCES `parents` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_parents_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `teachers`
--
ALTER TABLE `teachers`
  ADD CONSTRAINT `teachers_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `teacher_classes`
--
ALTER TABLE `teacher_classes`
  ADD CONSTRAINT `teacher_classes_class_id_foreign` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `teacher_classes_teacher_id_foreign` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
